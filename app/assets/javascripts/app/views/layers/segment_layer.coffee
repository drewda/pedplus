class App.Views.SegmentLayer extends Backbone.View
  initialize: ->
    @segmentDefaultStrokeWidth = @options.segmentDefaultStrokeWidth
    @segmentSelectedStrokeWidth = @options.segmentSelectedStrokeWidth
   
    @segments = @options.segments
    
    @layer = null
  enable: ->
    @segments.bind 'reset',   @render, this
    # @segments.bind 'add',     @render, this
    # @segments.bind 'remove',  @render, this
    # @segments.bind 'change',  @render, this
    
    if $('#segment-layer').length == 0
      @render()
  disable: ->
    @segments.unbind()
    @remove()
  remove: ->
    if @layer
      # masterRouter.map.map.off "move",    @layer.reload()
      # masterRouter.map.map.off "resize",  @layer.reload()
      masterRouter.map.map.remove(@layer)
    if $('#segment-layer').length > 0
      $('#segment-layer').remove()
  render: ->
    @remove()
    @layer = po.geoJson()
              .features(@segments.geojson().features)
              .id("segment-layer")
              .tile(false)
              .scale("fixed")
              .on "load", (e) ->
                connectedSegmentCids = []
                if location.hash.startsWith "#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/connect/c"
                  geoPointCid = location.hash.split('/').pop()
                  connectedSegmentCids = _.map masterRouter.geo_points.getByCid(geoPointCid).getSegments(), (s) => s.cid
         
                for f in e.features   
                  c = f.element
                  g = f.element = po.svg("g")
           
                  g.setAttribute "transform", c.getAttribute("transform")
         
                  c.setAttribute "id", "segment-line-#{f.data.cid}"
                  c.setAttribute "stroke-width", masterRouter.segment_layer.segmentDefaultStrokeWidth
         
         
                  if masterRouter.segments.getByCid(f.data.cid).get("selected")
                    c.setAttribute "class", "segment-line selected"
                  else if connectedSegmentCids.length > 0
                    if _.include connectedSegmentCids, f.data.cid
                      c.setAttribute "class", "segment-line connected"
                      connectedSegmentCids = _.without connectedSegmentCids, f.data.id
                    else
                      c.setAttribute "class", "segment-line"
                  else
                    c.setAttribute "class", "segment-line"
           
                  if masterRouter.segments.getByCid(f.data.cid).get("markedForDelete")? or
                     masterRouter.segments.getByCid(f.data.cid).isNew()
                    $(c).remove()
                  else
                    $(c).bind "click", (event) ->
                      cid = event.currentTarget.id.split('-').pop()
                      masterRouter.segments.getByCid(cid).toggle()
                                 
    masterRouter.map.map.add(@layer)
    # reorder the layers: we want SegmentLayer to be under GeoPointLayer
    #                     and we want both to be under the zoom buttons
    $('#osm-layer').after($('#segment-layer'))
    
    # masterRouter.map.map.on "move",    @layer.reload()
    # masterRouter.map.map.on "resize",  @layer.reload()
  change: ->
    # TODO
  setSegmentDefaultStrokeWidth: (segmentDefaultStrokeWidth) ->
    @segmentDefaultStrokeWidth = segmentDefaultStrokeWidth
    @render()
  setSegmentSelectedStrokeWidth: (segmentSelectedStrokeWidth) ->
    @segmentSelectedStrokeWidth = segmentSelectedStrokeWidth
    @render()