class App.Views.NewSegmentLayer extends Backbone.View
  initialize: ->
    @segmentDefaultStrokeWidth = @options.segmentDefaultStrokeWidth
    @segmentSelectedStrokeWidth = @options.segmentSelectedStrokeWidth
    
    @segments = @options.segments
  enable: ->  
    @segments.bind 'reset',  @change, this
    @segments.bind 'change', @change, this
    @segments.bind 'add',    @change, this
    @segments.bind 'remove', @change, this
    
    if $('#new-segment-layer').length == 0
      @render()
      @change()
  disable: ->
    @segments.unbind()
    $('#new-segment-layer').remove()
  render: ->
    layer = d3.select("#map-area svg").insert "svg:g", "#segment-layer" # behind GeoPoint's
    layer.attr "id", "new-segment-layer"

    masterRouter.map.map.on "move",    @reapplyTransform
    masterRouter.map.map.on "resize",  @reapplyTransform
  pathTransform: (d) ->
    scale = Math.pow(2, masterRouter.map.map.zoom()) * 256
    lp = masterRouter.map.map.locationPoint
      lon: 0
      lat: 0
    translate = [lp.x, lp.y]
    projection = d3.geo.mercator().translate(translate).scale(scale)
    return d3.geo.path().projection projection
  reapplyTransform: ->
    d3.select('#new-segment-layer').selectAll("path")
      .attr "d", (d) ->
        pathTransform = masterRouter.new_segment_layer.pathTransform(d)
        pathTransform d.geojson()
  # layerTransform: ->
  #   scale = Math.pow(2, masterRouter.map.map.zoom()) * 256
  #   translate = masterRouter.map.map.locationPoint
  #     lon: 0
  #     lat: 0
  #   transformation = "translate(#{translate.x}, #{translate.y}) scale(#{scale})"
  #   d3.select('#segment-layer').attr "transform", transformation
  change: (segment) ->
    # update the bound data
    segments = @segments.filter (s) =>
      if s.get('markedForDelete')
        false
      else if s.isNew()
        true
      else if s.get('moved')
        true

    segmentMarkers = d3.select('#new-segment-layer').selectAll("g").data segments, (d) =>
      d.cid

    # enter new elements              
    segmentMarkers.enter()
                  .append("svg:g")
                  .append("svg:path")
                  .attr "d", (d) =>
                    pathTransform = masterRouter.new_segment_layer.pathTransform(d)
                    pathTransform d.geojson()
                  .classed("segment-line", true)
                  .classed("black", true)
                  .classed 'selected', (d) =>
                    d.get 'selected'
                  .classed 'connected', (d) =>
                    masterRouter.currentRouteName.startsWith "mapConnectGeoPoint"
                  .attr "stroke-width", (d) =>
                    if d.selected
                      masterRouter.new_segment_layer.segmentSelectedStrokeWidth
                    else
                      masterRouter.new_segment_layer.segmentDefaultStrokeWidth
                  .attr "id", (d) =>
                    "segment-line-#{d.cid}"
                  .on 'click', (d) =>
                    d.toggle()

    # remove old elements
    segmentMarkers.exit().remove()     
    
    @reapplyTransform() # in case we've moved any GeoPoint's and their connected Segment's                  

  setSegmentDefaultStrokeWidth: (segmentDefaultStrokeWidth) ->
   @segmentDefaultStrokeWidth = segmentDefaultStrokeWidth
   @render()
  setSegmentSelectedStrokeWidth: (segmentSelectedStrokeWidth) ->
   @segmentSelectedStrokeWidth = segmentSelectedStrokeWidth
   @render()