class App.Views.GeoPointLayer extends Backbone.View
  initialize: ->
    @collection.bind 'reset',  @render, this
    @collection.bind 'change', @change, this
  render: ->
    $('#geo-point-layer').remove() if $('#geo-point-layer')
    layer = po.geoJson()
              .features(@collection.map (s) -> s.geojson())
              .id("geo-point-layer")
              .on "load", (e) ->
                for f in e.features
                  c = f.element
                  g = f.element = po.svg("g")
                  
                  c.setAttribute "class", "geo-point-circle"
                  c.setAttribute "id", "geo-point-circle-#{f.data.id}"
                  if geo_points.get(f.data.id).selected
                    c.setAttribute "r", "12"
                    c.setAttribute "fill", "#55ee33"
                  else
                    c.setAttribute "r", "8"
                    c.setAttribute "fill", "#000"
                                    
                  $(c).bind "click", (event) ->
                     id = Number event.currentTarget.id.split('-').pop()
                     geo_points.get(id).toggle()
                                        
    map.add(layer)
  change: ->
    # TODO