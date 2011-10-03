class App.Views.SegmentLayer extends Backbone.View
  initialize: ->
    @segmentDefaultStrokeWidth = @options.segmentDefaultStrokeWidth
    @segmentSelectedStrokeWidth = @options.segmentSelectedStrokeWidth
    
    @segments = @options.segments
  enable: ->  
    @segments.bind 'reset',  @change, this
    @segments.bind 'change', @change, this
    @segments.bind 'add',    @change, this
    @segments.bind 'remove', @change, this
    
    if $('#segment-layer').length == 0
      @render()
      @change()
  disable: ->
    @segments.unbind()
    $('#segment-layer').remove()
  render: ->
    layer = d3.select("#map-area svg").insert "svg:g", "#geo-point-layer" # behind GeoPoint's
    layer.attr "id", "segment-layer"

    map.on "move",    @reapplyTransform
    map.on "resize",  @reapplyTransform
  pathTransform: (d) ->
    scale = Math.pow(2, map.zoom()) * 256
    lp = map.locationPoint
      lon: 0
      lat: 0
    translate = [lp.x, lp.y]
    projection = d3.geo.mercator().translate(translate).scale(scale)
    return d3.geo.path().projection projection
  reapplyTransform: ->
    d3.select('#segment-layer').selectAll("path")
      .attr "d", (d) ->
        pathTransform = masterRouter.segment_layer.pathTransform(d) 
        pathTransform d.geojson()
  # layerTransform: ->
  #   scale = Math.pow(2, map.zoom()) * 256
  #   translate = map.locationPoint
  #     lon: 0
  #     lat: 0
  #   transformation = "translate(#{translate.x}, #{translate.y}) scale(#{scale})"
  #   d3.select('#segment-layer').attr "transform", transformation
  change: (segment) ->
    # update the bound data
    segments = @segments.reject (s) => s.get('markedForDelete')

    segmentMarkers = d3.select('#segment-layer').selectAll("g").data segments, (d) =>
      d.cid

    # enter new elements              
    segmentMarkers.enter()
      .append("svg:g")
      .append("svg:path")
        .attr "d", (d) ->
          pathTransform = masterRouter.segment_layer.pathTransform(d) 
          pathTransform d.geojson()
        .classed 'selected', (d) ->
          d.get 'selected'
        .classed 'connected', (d) ->
          masterRouter.currentRouteName.startsWith "mapConnectGeoPoint"
        .attr "stroke-width", (d) ->
          if d.selected
            masterRouter.segment_layer.segmentSelectedStrokeWidth
          # else if connected
          else
            masterRouter.segment_layer.segmentDefaultStrokeWidth
        .classed("segment-line", true)
        .attr "id", (d) -> 
          "segment-line-#{d.cid}"
        .on 'click', (d) -> 
          d.toggle()

    # if there is a changed Segment, go in and modify it      
    if segment and !segment.models
      changedSegmentMarkers = segmentMarkers.filter (d, i) =>
        d.cid == segment.cid
      # select
      changedSegmentMarkers.selectAll('path')
        .attr "stroke-width", (d) ->
          if d.get 'selected'
            masterRouter.segment_layer.segmentSelectedStrokeWidth
          else
            masterRouter.segment_layer.segmentDefaultStrokeWidth
        .classed "selected", (d) ->
          d.get 'selected'
      # move is handled by GeoPoint move

    # remove old elements
    segmentMarkers.exit().remove()                            

  setSegmentDefaultStrokeWidth: (segmentDefaultStrokeWidth) ->
    @segmentDefaultStrokeWidth = segmentDefaultStrokeWidth
    @render()
  setSegmentSelectedStrokeWidth: (segmentSelectedStrokeWidth) ->
    @segmentSelectedStrokeWidth = segmentSelectedStrokeWidth
    @render()