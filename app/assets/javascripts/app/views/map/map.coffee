class App.Views.Map extends Backbone.View
  initialize: ->
    @projects = @options.projects
    
    # will be used in @checkForDoubleTapBeforeDrawingGeoPoint()
    # and in @checkForDoubleTapBeforeMovingGeoPoint()
    @latestTap = null
    
    @map = null
    # @osmGrayLayer = null
    @osmColorLayer = null
    @bingAerialLayer = null
    
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
    
    # OpenStreetMap layer
    ### 
    URBPED-16: disable gray layer for now, as MapQuest does not provide differently styled tiles
    if/when we switch to Esri base maps, they have a gray tile set that we can use:
    http://www.esri.com/news/releases/11-4qtr/new-esri-basemap-highlights-thematic-content.html
    ###
    # @osmGrayLayer = po.image()
    #             .url(po.url('http://otile{S}.mqcdn.com/tiles/1.0.0/osm/{Z}/{X}/{Y}.png').hosts(["1", "2", "3", "4"]))
    #             .id("osm-gray-layer")
    # @map.add(@osmGrayLayer)

    # if there is a project and that project uses the Bing aerial base map, set up that layer
    if masterRouter.projects.getCurrentProject()
      if masterRouter.projects.getCurrentProject().get('base_map') == 'bing'
        bingAerialUrl = "http:\/\/ecn.{subdomain}.tiles.virtualearth.net\/tiles\/a{quadkey}.jpeg?g=914&mkt={culture}"
        bingAerialUrlSubdomains = ["t0","t1","t2","t3"]
        @bingAerialLayer = po.image()
                    .url(@bingAerialTemplate(bingAerialUrl, bingAerialUrlSubdomains))
                    .id("osm-color-layer") # TODO: change the layer id, which means also changing the layer bindings
        @map.add @bingAerialLayer

      # if not (by default), show the OSM tiles from MapQuest
      else
        @osmColorLayer = po.image()
                    .url(po.url('http://otile{S}.mqcdn.com/tiles/1.0.0/osm/{Z}/{X}/{Y}.png').hosts(["1", "2", "3", "4"]))
                    .id("osm-color-layer")
        @map.add(@osmColorLayer)

    # TODO: clean this up
    # if not (by default), show the OSM tiles from MapQuest
    else
      @osmColorLayer = po.image()
                  .url(po.url('http://otile{S}.mqcdn.com/tiles/1.0.0/osm/{Z}/{X}/{Y}.png').hosts(["1", "2", "3", "4"]))
                  .id("osm-color-layer")
      @map.add(@osmColorLayer)
    
    # add the compass to the top right of the screen
    @map.add(po.compass().position('top-right'))

    
  # Returns a Bing URL template given a string and a list of subdomains.
  # code from http://polymaps.org/ex/bing.html
  bingAerialTemplate: (url, subdomains) ->
    n = subdomains.length
    salt = ~~(Math.random() * n) # per-session salt

    # Returns the given coordinate formatted as a 'quadkey'.
    quad = (column, row, zoom) ->
      key = ""
      for i in [1..zoom]
        key += (((row >> zoom - i) & 1) << 1) | ((column >> zoom - i) & 1)
      return key

    return (c) ->
      quadKey = quad(c.column, c.row, c.zoom)
      server = Math.abs(salt + c.column + c.row + c.zoom) % n
      return url
          .replace("{quadkey}", quadKey)
          .replace("{subdomain}", subdomains[server])

  setOsmLayer: (mode = "color") ->
    if mode == "color"
      # $('#osm-color-layer').show()
      # $('#osm-gray-layer').hide()
      $('#osm-color-layer').css('opacity', '1.0')
    else if mode == "gray"
      # $('#osm-color-layer').hide()
      # $('#osm-gray-layer').show()
      $('#osm-color-layer').css('opacity', '.5')

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
    $(".segment-line").svg().removeClass("connected selected red1 red2 red3 red4 red5 blue1 blue2 blue3 blue4 blue5").css("stroke", '')
    masterRouter.segment_layer.layer.reload() if masterRouter.segment_layer.layer?
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
        start_longitude: previousGeoPoint.get "longitude"
        start_latitude: previousGeoPoint.get "latitude"
        end_longitude: newGeoPoint.get "longitude"
        end_latitude: newGeoPoint.get "latitude"
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
    geoPointToMoveOldLongitude = geoPointToMove.get 'longitude'
    geoPointToMoveOldLatitude = geoPointToMove.get 'latitude'
    geoPointToMove.set
      longitude: pointLocation.lon
      latitude: pointLocation.lat
    
    # move the connected segments
    _.each geoPointToMove.getSegments(), (s) =>
      $("#segment-layer #segment-line-#{s.cid}").remove()
      # figure out whether it's the start or the end coordinates that need to be
      # changed for the segment
      if Number(s.get "start_longitude") == Number(geoPointToMoveOldLongitude) and 
         Number(s.get "start_latitude") == Number(geoPointToMoveOldLatitude)
        s.set
          moved: true
          start_longitude: pointLocation.lon
          start_latitude: pointLocation.lat
      else if Number(s.get "end_longitude") == Number(geoPointToMoveOldLongitude) and 
              Number(s.get "end_latitude") == Number(geoPointToMoveOldLatitude)
        s.set
          moved: true
          end_longitude: pointLocation.lon
          end_latitude: pointLocation.lat

    # create a MapEdit (the record that will be sent to the server)
    mapEdit = new App.Models.MapEdit
    masterRouter.map_edits.add mapEdit
    mapEdit.set
      geo_points: [geoPointToMove.unset 'geo_point_on_segments']
      segments: geoPointToMove.getSegments()
    
    # for some reason the selected styling is removed from the GeoPoint, so we'll kludge it in
    $("#geo-point-circle-#{geoPointToMove.cid}").svg().addClass("selected").attr "r", masterRouter.geo_point_layer.geoPointSelectedRadius
    
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/#{geoPointToMove.cid}", true
  connectGeoPointMode: ->
    geoPointToConnect = masterRouter.geo_points.selected()[0]
    
    $("#geo-point-circle-#{geoPointToConnect.cid}").svg().addClass "connected"
    for s in geoPointToConnect.getSegments()
      $("#segment-line-#{s.cid}").svg().addClass "connected"
  
  enableSegmentWorkingAnimation: ->
    @segmentWorkingAnimation = setInterval "masterRouter.map.doSegmentWorkingAnimation()", 500
  disableSegmentWorkingAnimation: ->
    @segmentWorkingAnimation = clearInterval @segmentWorkingAnimation
    $('.segment-line').svg().removeAttr 'style'
  doSegmentWorkingAnimation: ->
    $('.segment-line').svg().css 'stroke', (index, value) =>
      "rgb(#{Math.floor(Math.random() * 256)}, 0, 0)"