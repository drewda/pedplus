class Smartphone.Views.SegmentLayer extends Backbone.View
  initialize: ->
    @segmentDefaultStrokeWidth = @options.segmentDefaultStrokeWidth
    @segmentSelectedStrokeWidth = @options.segmentSelectedStrokeWidth
   
    @geojson = @options.geojson
    
    @layer = null
  enable: ->
    if $('#segment-layer').length == 0
      @render()
  disable: ->
    @remove()
  remove: ->
    if @layer
      masterRouter.map.map.remove(@layer)
    if $('#segment-layer').length > 0
      $('#segment-layer').remove()
  render: ->
    @remove()
    @layer = po.geoJson()
              .features(@geojson)
              .id("segment-layer")
              .tile(false)
              .scale("fixed")
              .on("load", @loadFeatures)
              .on("show", @showFeatures)

                                 
    masterRouter.map.map.add(@layer)
    # reorder the layers: we want SegmentLayer to be under GeoPointLayer
    #                     and we want both to be under the zoom buttons
    $('#osm-color-layer').after($('#segment-layer'))

  loadFeatures: (e) ->
    for f in e.features   
      c = f.element

      c.setAttribute "id", "segment-line-#{f.data.cid}"
      c.setAttribute "stroke-width", masterRouter.segment_layer.segmentDefaultStrokeWidth

  showFeatures: (e) ->

    for f in e.features   
      c = f.element

      c.setAttribute "class", "segment-line black"

      # c.removeAttribute "class"
  
  setSegmentDefaultStrokeWidth: (segmentDefaultStrokeWidth) ->
    @segmentDefaultStrokeWidth = segmentDefaultStrokeWidth
    @render()
  setSegmentSelectedStrokeWidth: (segmentSelectedStrokeWidth) ->
    @segmentSelectedStrokeWidth = segmentSelectedStrokeWidth
    @render()