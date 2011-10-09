class App.Views.Map extends Backbone.View
  initialize: ->
    @projects = @options.projects
    
    # will be used in @checkForDoubleTapBeforeDrawingGeoPoint()
    # and in @checkForDoubleTapBeforeMovingGeoPoint()
    @latestTap = null
    
    @map = null
    @osmLayer = null
    
    @segmentWorkingAnimation = null
    
    @render()
  render: ->
    window.po = org.polymaps
    @map = po.map()
       .container(document.getElementById("map-area").appendChild(po.svg("svg")))
       .add(po.drag())
       .add(po.wheel())
       .add(po.touch())
       .add(po.arrow())
    @map.add(po.compass().position('top-right'))
    
    @osmGrayLayer = po.image()
                .url(po.url('''http://{S}tile.cloudmade.com
                /b8f01ac08d4242be9c2876f862c8ef2c
                /46118/256/{Z}/{X}/{Y}.png''')
                .hosts(["a.", "b.", "c.", ""]))
                .id("osm-gray-layer")
    @map.add(@osmGrayLayer)
    @osmColorLayer = po.image()
                .url(po.url('''http://{S}tile.cloudmade.com
                /b8f01ac08d4242be9c2876f862c8ef2c
                /997/256/{Z}/{X}/{Y}.png''')
                .hosts(["a.", "b.", "c.", ""]))
                .id("osm-color-layer")
    @map.add(@osmColorLayer)
    
  setOsmLayer: (mode = "color") ->
    if mode == "color"
      $('#osm-color-layer').show()
      $('#osm-gray-layer').hide()
    else if mode == "gray"
      $('#osm-color-layer').hide()
      $('#osm-gray-layer').show()

  centerMap: ->
    if currentProject = @projects.getCurrentProject()
      if currentProject.get 'southwest_latitude'
        @map.extent [
          lat: currentProject.get 'northeast_latitude'
          lon: currentProject.get 'northeast_longitude'
        ,
          lat: currentProject.get 'southwest_latitude'
          lon: currentProject.get 'southwest_longitude'
        ]
        @map.zoomBy -1
      else
        @centerMapAtCurrentPosition()
    else
      @centerMapAtCurrentPosition()
  centerMapAtCurrentPosition: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) ->
        masterRouter.map.map.center
          lat: position.coords.latitude
          lon: position.coords.longitude
        masterRouter.map.map.zoom 16
    else # Berkeley Way
      @map.center
        lat: 37.871592
        lon: 122.272747
  resetMap: (showGeoPointLayer, showSegmentLayer) ->
    # enable and disable layers
    if showGeoPointLayer
      masterRouter.geo_point_layer.enable()
    else
      masterRouter.geo_point_layer.disable()
    
    if showSegmentLayer
      masterRouter.segment_layer.enable()
      masterRouter.new_segment_layer.enable()
    else
      masterRouter.segment_layer.disable()
      masterRouter.new_segment_layer.disable()
    
    # remove click listeners
    $('#osm-color-layer, #osm-gray-layer').unbind 'click'
    $('#osm-color-layer, #osm-gray-layer').unbind 'dblclick'
    $('#osm-color-layer, #osm-gray-layer').unbind 'touchstart'
    
    # remove coloring
    $(".geo-point-circle.connected").svg().removeClass("connected").addClass("selected")
    # $(".geo-point-circle").svg().removeClass("connected").removeClass("selected")
    $(".segment-line").svg().removeClass("connected").removeClass("selected").css("stroke", '')
  mapMode: ->
    $('#osm-color-layer').bind 'dblclick', (event) => @drawGeoPoint(event, false)
    $('#osm-color-layer').bind 'touchstart', (event) => @checkForDoubleTapBeforeDrawingGeoPoint(event)
  checkForDoubleTapBeforeDrawingGeoPoint: (event) ->
    # only log taps with one touch
    # because taps with two touches are probably
    # a pinch-to-zoom gesture
    if event.originalEvent.touches.length == 1
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
    pointLocation = @map.pointLocation
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
    $('#osm-color-layer').bind 'dblclick', (event) => @moveGeoPoint(event, false)
    $('#osm-color-layer').bind 'touchstart', (event) => @checkForDoubleTapBeforeMovingGeoPoint(event)
  checkForDoubleTapBeforeMovingGeoPoint: (event) ->
    # only log taps with one touch
    # because taps with two touches are probably
    # a pinch-to-zoom gesture
    if event.originalEvent.touches.length == 1
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
    pointLocation = @map.pointLocation
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
    
    # TODO:
    _.each geoPointToMove.getSegments(), (s) =>
      $("#segment-layer #segment-line-#{s.cid}").remove()
      s.set
        moved: true
    
    # for some reason the selected styling is removed from the GeoPoint, so we'll kludge it in
    $("#geo-point-circle-#{geoPointToMove.cid}").svg().addClass("selected").attr "r", masterRouter.geo_point_layer.geoPointSelectedRadius
    
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/#{geoPointToMove.cid}", true
  connectGeoPointMode: ->
    geoPointToConnect = masterRouter.geo_points.selected()[0]
    
    $("#geo-point-circle-#{geoPointToConnect.cid}").svg().addClass "connected"
    for s in geoPointToConnect.getSegments()
      $("#segment-line-#{s.cid}").svg().addClass "connected"
      
  modelMode: (modelKind) ->
    redColors = ['#FCBBA1', '#FC9272', '#FB6A4A', '#EF3B2C', '#CB181D', '#99000D']
    
    if modelKind == "permeability"
      masterRouter.segments.each (s) =>
        console.log s.get('permeabilityClass')
        $("#segment-line-#{s.cid}").svg().css('stroke', redColors[s.get('permeabilityClass') - 1])
      
    else if modelKind == "proximity"
      console.log "prox"
      
  measureMode: ->
    blueColors = ['#C6DBEF', '#9ECAE1', '#6BAED6', '#4292C6', '#2171B5', '#084594']
  
  enableSegmentWorkingAnimation: ->
    @segmentWorkingAnimation = setInterval "masterRouter.map.doSegmentWorkingAnimation()", 500
  disableSegmentWorkingAnimation: ->
    @segmentWorkingAnimation = clearInterval @segmentWorkingAnimation
  doSegmentWorkingAnimation: ->
    $('.segment-line').svg().css 'stroke', (index, value) =>
      "rgb(#{Math.floor(Math.random() * 256)}, 0, 0)"