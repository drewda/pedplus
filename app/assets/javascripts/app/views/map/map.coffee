class App.Views.Map extends Backbone.View
  initialize: ->
    @projects = @options.projects
    
    # will be used in @checkForDoubleTapBeforeDrawingGeoPoint()
    # and in @checkForDoubleTapBeforeMovingGeoPoint()
    @latestTap = null
    
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
        @moveGeoPointMode()
      when "mapConnectGeoPoint"
        @resetMap()
        @connectGeoPointMode()
      when "mapDeleteGeoPoint"
        @resetMap()
      when "mapSelectedSegment"
        @resetMap()
      when "mapDeleteSegment"
        @resetMap()
      
  resetMap: ->
    # remove click listeners
    $('#osm-layer').unbind 'click'
    $('#osm-layer').unbind 'dblclick'
    $('#osm-layer').unbind 'touchstart'
    
    # remove coloring -- if coming from connectGeoPointMode
    $(".geo-point-circle.connected").svg().removeClass("connected").addClass("selected")
    $(".segment-line.connected").svg().removeClass("connected")
  mapMode: ->
    $('#osm-layer').bind 'dblclick', (event) => @drawGeoPoint(event, false)
    $('#osm-layer').bind 'touchstart', (event) => @checkForDoubleTapBeforeDrawingGeoPoint(event)
  checkForDoubleTapBeforeDrawingGeoPoint: (event) ->
    if @latestTap 
      if (new Date() - @latestTap) < 400
        @drawGeoPoint(event, true)
    @latestTap = new Date()
  drawGeoPoint: (event, touch) ->
    if !touch
      x = event.pageX - $('#map-area').offset().left
      y = event.pageY - $('#map-area').offset().top
    else if touch
      event.preventDefault()
      x = event.originalEvent.targetTouches[0].pageX - $('#map-area').offset().left
      y = event.originalEvent.targetTouches[0].pageY - $('#map-area').offset().top
    
    mapEdit = new App.Models.MapEdit
    masterRouter.map_edits.add mapEdit
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
  moveGeoPointMode: ->  
    $('#osm-layer').bind 'dblclick', (event) => @moveGeoPoint(event, false)
    $('#osm-layer').bind 'touchstart', (event) => @checkForDoubleTapBeforeMovingGeoPoint(event)
  checkForDoubleTapBeforeMovingGeoPoint: (event) ->
    if @latestTap 
      if (new Date() - @latestTap) < 400
        @moveGeoPoint(event, true)
    @latestTap = new Date()
  moveGeoPoint: (event, touch) ->
    if !touch
      x = event.pageX - $('#map-area').offset().left
      y = event.pageY - $('#map-area').offset().top
    else if touch
      event.preventDefault()
      x = event.originalEvent.targetTouches[0].pageX - $('#map-area').offset().left
      y = event.originalEvent.targetTouches[0].pageY - $('#map-area').offset().top
    pointLocation = map.pointLocation
      x: x
      y: y
    geoPointToMove = masterRouter.geo_points.selected()[0]
    geoPointToMove.set
      longitude: pointLocation.lon
      latitude: pointLocation.lat
    mapEdit = new App.Models.MapEdit
    masterRouter.map_edits.add mapEdit
    mapEdit.set
      geo_points: [geoPointToMove.unset 'geo_point_on_segments']
    masterRouter.segments.trigger "change"
    
    # for some reason the selected styling is removed from the GeoPoint, so we'll kludge it in
    $("#geo-point-circle-#{geoPointToMove.cid}").svg().addClass("selected").attr "r", masterRouter.geo_point_layer.geoPointSelectedRadius
    
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/#{geoPointToMove.cid}", true
  connectGeoPointMode: ->
    geoPointToConnect = masterRouter.geo_points.selected()[0]
    
    $("#geo-point-circle-#{geoPointToConnect.cid}").svg().addClass "connected"
    for s in geoPointToConnect.getSegments()
      $("#segment-line-#{s.cid}").svg().addClass "connected"