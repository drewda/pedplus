class App.Views.Map extends Backbone.View
  initialize: ->
    @render()
    masterRouter.bind "route:mapView", @mapViewMode
    masterRouter.bind "route:mapEdit", @mapEditMode
    masterRouter.bind "route:mapMoveGeoPoint", @mapMoveGeoPointMode
    masterRouter.bind "route:mapConnectGeoPoint", @mapConnectGeoPointMode
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

    map.add(po.compass()
            .pan("none"))
            
    @centerMapAtCurrentPosition()
  centerMapAtCurrentPosition: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) ->
        map.center
          lat: position.coords.latitude
          lon: position.coords.longitude
        map.zoom 16
  mapViewMode: ->
    $('#osm-layer').unbind 'click'
  mapEditMode: ->
    # remove coloring -- if coming from connectGeoPointMode
    $(".geo-point-circle.connected").svg().removeClass("connected").addClass("selected")
    $(".segment-line.connected").svg().removeClass("connected")
    
    $('#osm-layer').bind 'click', (event) =>
      x = event.pageX - $('#map-area').offset().left
      y = event.pageY - $('#map-area').offset().top
      pointLocation = map.pointLocation
        x: x
        y: y
      newGeoPoint = geo_points.create
                       longitude: pointLocation.lon
                       latitude: pointLocation.lat
                       # TODO: add project association -- in Rails data model as well
      # if a GeoPoint is currently selected, we will create a Segment
      # to connect that GeoPoint with the new GeoPoint
      if geo_points.selected().length == 1
        previousGeoPoint = geo_points.selected()[0]
        newSegment = segments.create
          ped_project_id: 0 # TODO: add project association
        ,
          success: -> 
            geo_point_on_segments.create
              geo_point_id: previousGeoPoint.id
              segment_id: newSegment.id
            ,
              success: ->
                geo_point_on_segments.create
                  geo_point_id: newGeoPoint.id
                  segment_id: newSegment.id
                ,
                  success: ->
                    masterRouter.fetchData
                      success: ->
                        geo_points.get(newGeoPoint.id).select()
  mapMoveGeoPointMode: ->
    $('#osm-layer').unbind 'click' # disable editing mode
    
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