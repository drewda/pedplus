class App.Views.GeoPointLayer extends Backbone.View
  initialize: ->
    @collection.bind 'reset', @render, this
    @collection.bind 'change', @change, this
  transform: (d) ->
    lp = map.locationPoint
      lon: d.get('longitude')
      lat: d.get('latitude')
    return "translate(#{lp.x}, #{lp.y})"
  render: ->
    console.log "rendering GeoPointLayer: #{@collection.length}"
    
    layer = d3.select("#map-area svg").insert "svg:g", ".compass"
    layer.attr "id", "geo-point-layer"
    
    map.on "move", @redraw
    map.on "resize", @redraw
      
    @change()
  change: ->
    console.log "changing GeoPointLayer: #{@collection.length}"
    
    marker = d3.select('#geo-point-layer').selectAll("g")
                  .data(@collection.models)
                  .enter().append("svg:g")
                  .attr("transform", @transform)
    
    marker.append("svg:circle")
        .attr("fill", '#000000')
        .attr("r", "8")
        .attr "id", (d) ->
          "geo-point-circle-#{d.id}"
        .on 'click', (d) ->
          d.toggle()
  redraw: ->
    d3.select('#geo-point-layer').selectAll("g").attr "transform", (d) =>
      lp = map.locationPoint
        lon: d.get('longitude')
        lat: d.get('latitude')
      return "translate(#{lp.x}, #{lp.y})"
    