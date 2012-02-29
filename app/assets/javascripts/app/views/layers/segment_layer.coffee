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
              .on("load", @loadFeatures)
              .on("show", @showFeatures)

                                 
    masterRouter.map.map.add(@layer)
    # reorder the layers: we want SegmentLayer to be under GeoPointLayer
    #                     and we want both to be under the zoom buttons
    $('#osm-color-layer').after($('#segment-layer'))
    
    # masterRouter.map.map.on "move",    @layer.reload()
    # masterRouter.map.map.on "resize",  @layer.reload()
  loadFeatures: (e) ->
    for f in e.features   
      c = f.element

      c.setAttribute "id", "segment-line-#{f.data.cid}"
      c.setAttribute "stroke-width", masterRouter.segment_layer.segmentDefaultStrokeWidth
      
      if masterRouter.segments.getByCid(f.data.cid).get("markedForDelete")? or
        masterRouter.segments.getByCid(f.data.cid).get("moved")? or
         masterRouter.segments.getByCid(f.data.cid).isNew()
        $(c).remove()
      else
        $(c).bind "click", (event) ->
          cid = event.currentTarget.id.split('-').pop()
          masterRouter.segments.getByCid(cid).toggle()
  showFeatures: (e) ->
    connectedSegmentCids = []
    if location.hash.startsWith "#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/connect/c"
      geoPointCid = location.hash.split('/').pop()
      connectedSegmentCids = _.map masterRouter.geo_points.getByCid(geoPointCid).getSegments(), (s) => s.cid

    for f in e.features   
      c = f.element

      c.removeAttribute "class"

      if masterRouter.currentRouteName.startsWith "modelPermeability"
        colorClass = masterRouter.segments.getByCid(f.data.cid).get('permeabilityClass')
        c.setAttribute "class", "red#{colorClass}"
      else if masterRouter.currentRouteName.startsWith "measureSelectedCountSession" or 
              masterRouter.currentRouteName.startsWith "measureSelectedSegment"
        if masterRouter.currentRouteName.startsWith "measureSelectedCountSession"
          selectedCountSessionId = masterRouter.currentRouteName.split(':').pop()
          selectedSegmentId = masterRouter.count_sessions.get(selectedCountSessionId).get('segment_id')
        else if masterRouter.currentRouteName.startsWith "measureSelectedSegment"
          selectedSegmentCid = masterRouter.currentRouteName.split(':').pop()
          selectedSegmentId = masterRouter.segments.getByCid(selectedSegmentCid).id

        colorClass = masterRouter.segments.getByCid(f.data.cid).get('measuredClass')
        if f.data.id == selectedSegmentId
          c.setAttribute "class", "segment-line selected"
        else if colorClass > 0
          c.setAttribute "class", "segment-line blue#{colorClass}"
        else
          c.setAttribute "class", "segment-line black"
    # else if masterRouter.currentRouteName.startsWith "measurePredictions"
      else if masterRouter.segments.getByCid(f.data.cid).get("selected")
        c.setAttribute "class", "segment-line selected black"
      else if connectedSegmentCids.length > 0
        if _.include connectedSegmentCids, f.data.cid
          c.setAttribute "class", "segment-line connected black"
          connectedSegmentCids = _.without connectedSegmentCids, f.data.id
        else
          c.setAttribute "class", "segment-line black"
      else
        c.setAttribute "class", "segment-line black"
  
  change: ->
    # TODO
  setSegmentDefaultStrokeWidth: (segmentDefaultStrokeWidth) ->
    @segmentDefaultStrokeWidth = segmentDefaultStrokeWidth
    @render()
  setSegmentSelectedStrokeWidth: (segmentSelectedStrokeWidth) ->
    @segmentSelectedStrokeWidth = segmentSelectedStrokeWidth
    @render()