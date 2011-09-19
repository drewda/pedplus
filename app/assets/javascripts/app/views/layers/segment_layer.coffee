class App.Views.SegmentLayer extends Backbone.View
  initialize: ->
    @collection.bind 'reset',  @render, this
    @collection.bind 'change', @change, this
    @collection.bind 'redraw', @render, this
    # @collection.bind 'add',    @render, this
  render: ->
    $('#segment-layer').remove() if $('#segment-layer')
    layer = po.geoJson()
              .features(@collection.map (s) -> s.geojson())
              .id("segment-layer")
              .on "load", (e) ->
                connectedSegmentIds = []
                if location.hash.startsWith('#map/edit/geo_point/connect')
                  geoPointId = location.hash.split('/').pop()
                  connectedSegmentIds = _.map geo_points.get(geoPointId).segments(), (s) => s.id
                
                for f in e.features
                  c = f.element
                  g = f.element = po.svg("g")
                  
                  c.setAttribute "class", "segment-line"
                  c.setAttribute "id", "segment-line-#{f.data.id}"
                  c.setAttribute "stroke-width", "5"
                  
                  if connectedSegmentIds.length > 0
                    if _.include connectedSegmentIds, f.data.id
                      c.setAttribute "class", "segment-line connected"
                      connectedSegmentIds = _.without connectedSegmentIds, f.data.id
                                    
                  $(c).bind "click", (event) ->
                    id = Number event.currentTarget.id.split('-').pop()
                    segments.get(id).toggle()
                                        
    map.add(layer)
    # reorder the layers: we want SegmentLayer to be under GeoPointLayer
    #                     and we want both to be under the zoom buttons
    $('#osm-layer').after($('#segment-layer'))
  change: ->
    # TODO