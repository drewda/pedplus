class App.Views.Map extends Backbone.View
  initialize: ->
    @projects = @options.projects
    
    @render()
    masterRouter.bind "all", @changeRoute, this
  render: ->
    window.po = org.polymaps
 
    window.map = po.map()
       .container(document.getElementById("map-area").appendChild(po.svg("svg")))
       .add(po.drag())
       .add(po.wheel())
       .add(po.touch())
       .add(po.arrow())

    osmLayer = po.image()
                .url(po.url('''http://{S}tile.cloudmade.com
                /b8f01ac08d4242be9c2876f862c8ef2c
                /997/256/{Z}/{X}/{Y}.png''')
                .hosts(["a.", "b.", "c.", ""]))
                .id("osm-layer")
    map.add(osmLayer)
  centerMap: ->
    if currentProject = @projects.getCurrentProject()
      if geographic_center = currentProject.get('geographic_center')
        map.center
          lat: geographic_center.latitude
          lon: geographic_center.longitude
      else
        @centerMapAtCurrentPosition()
    else
      @centerMapAtCurrentPosition()
  centerMapAtCurrentPosition: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) ->
        map.center
          lat: position.coords.latitude
          lon: position.coords.longitude
        map.zoom 16
    else # Berkeley Way
      map.center
        lat: 37.871592
        lon: 122.272747
  changeRoute: (route) ->
    route = route.split(':').pop()
    switch route
      when "projectOpen"
        @resetMap()
        @centerMap()
      when "project"
        @resetMap()
        @centerMap()
      when "map"
        @resetMap()
        @mapMode()
      when "mapSelectedGeoPoint"
        @resetMap()
        @mapMode()
      when "mapMoveGeoPoint"
        @resetMap()
      when "mapConnectGeoPoint"
        @resetMap()
      when "mapDeleteGeoPoint"
        @resetMap()
      when "mapSelectedSegment"
        @resetMap()
      when "mapDeleteSegment"
        @resetMap()
      
  resetMap: ->
    # remove click listeners
    $('#osm-layer').unbind 'click'
    
    # remove coloring -- if coming from connectGeoPointMode
    $(".geo-point-circle.connected").svg().removeClass("connected").addClass("selected")
    $(".segment-line.connected").svg().removeClass("connected")
  mapMode: ->
    $('#osm-layer').bind 'click', (event) =>
      # TODO: do something about po.drag()
      mapEdit = new App.Models.MapEdit
      masterRouter.map_edits.add mapEdit
      x = event.pageX - $('#map-area').offset().left
      y = event.pageY - $('#map-area').offset().top
      pointLocation = map.pointLocation
        x: x
        y: y
      newGeoPoint = new App.Models.GeoPoint
                       longitude: pointLocation.lon
                       latitude: pointLocation.lat
                       project_id: @projects.getCurrentProjectId()
      masterRouter.geo_points.add newGeoPoint
      mapEdit.set
        geo_points: [newGeoPoint]
      # if a GeoPoint is currently selected, we will create a Segment
      # to connect that GeoPoint with the new GeoPoint
      if masterRouter.geo_points.selected().length == 1
        previousGeoPoint = masterRouter.geo_points.selected()[0]
        
        newSegment = new App.Models.Segment
          project_id: @projects.getCurrentProjectId()
        mapEdit.set
          segments: [newSegment]
        
        if previousGeoPoint.isNew()
          gposPreviousGeoPoint = new App.Models.GeoPointOnSegment
            geo_point_cid: previousGeoPoint.cid
            segment_cid: newSegment.cid
            project_id: @projects.getCurrentProjectId()
        else
          gposPreviousGeoPoint = new App.Models.GeoPointOnSegment
            geo_point_id: previousGeoPoint.id
            segment_cid: newSegment.cid
            project_id: @projects.getCurrentProjectId()
        gposNewGeoPoint = new App.Models.GeoPointOnSegment
          geo_point_cid: newGeoPoint.cid
          segment_cid: newSegment.cid
          project_id: @projects.getCurrentProjectId()
        mapEdit.set
          geo_point_on_segments: [gposPreviousGeoPoint, gposNewGeoPoint]
        
        masterRouter.geo_point_on_segments.add gposPreviousGeoPoint
        masterRouter.geo_point_on_segments.add gposNewGeoPoint
        masterRouter.segments.add newSegment
      
      newGeoPoint.select()

  mapMoveGeoPointMode: ->
    geoPointId = arguments[0]
    
    $('#osm-layer').bind 'click', (event) =>
      x = event.pageX - $('#map-area').offset().left
      y = event.pageY - $('#map-area').offset().top
      pointLocation = map.pointLocation
        x: x
        y: y
      geo_points.selected()[0].save
        longitude: pointLocation.lon
        latitude: pointLocation.lat
      ,
        success: (model, response) ->
          masterRouter.fetchData
            success: ->
              geo_points.get(model.id).select()
              $('#osm-layer').unbind 'click'
              $('#geo-point-move-button').attr("checked", false).button "refresh"
              masterRouter.navigate "map/edit", true
        error: (model, response) ->
          console.log "ERROR moving GeoPoint"
  mapConnectGeoPointMode: ->
    $('#osm-layer').unbind 'click'
    
    geoPointId = arguments[0]
    
    $("#geo-point-circle-#{geoPointId}").svg().addClass "connected"
    for s in geo_points.get(geoPointId).segments()
      $("#segment-line-#{s.id}").svg().addClass "connected"