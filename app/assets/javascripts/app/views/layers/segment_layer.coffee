class App.Views.SegmentLayer extends Backbone.View
  initialize: ->
    @collection.bind 'reset',   @render, this
    @collection.bind 'add',     @render, this
    @collection.bind 'remove',  @render, this
    @collection.bind 'change',  @render, this
  render: ->
    $('#segment-layer').remove() if $('#segment-layer')
    layer = po.geoJson()
              .features(@collection.geojson().features)
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
                
                  c.setAttribute "class", "segment-line"
                  c.setAttribute "id", "segment-line-#{f.data.cid}"
                  c.setAttribute "stroke-width", "5"
                
                  if connectedSegmentCids.length > 0
                    if _.include connectedSegmentCids, f.data.cid
                      c.setAttribute "class", "segment-line connected"
                      connectedSegmentCids = _.without connectedSegmentCids, f.data.id
                  
                  if masterRouter.segments.getByCid(f.data.cid)?.get("markedForDelete")?
                    $(c).remove()
                  else
                    $(c).bind "click", (event) ->
                      cid = event.currentTarget.id.split('-').pop()
                      masterRouter.segments.getByCid(cid).toggle()
                                        
    map.add(layer)
    # reorder the layers: we want SegmentLayer to be under GeoPointLayer
    #                     and we want both to be under the zoom buttons
    $('#osm-layer').after($('#segment-layer'))
  change: ->
    # TODO