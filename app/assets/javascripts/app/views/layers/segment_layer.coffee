class App.Views.SegmentLayer extends Backbone.View
  initialize: ->
    # @collection.bind 'reset', @draw()
    @collection.bind 'change', @change()
  transform: (d) ->
    lp = map.locationPoint
      lon: d.geometry.coordinates[0][0]
      lat: d.geometry.coordinates[0][1]
    console.log "translate(#{lp.x}, #{lp.y})"
    return "translate(#{lp.x}, #{lp.y})"
  draw: ->
    # console.log "rendering SegmentLayer: #{@collection.length}"
    
    layer = d3.select("#map-area svg").insert "svg:g", ".compass"
    
    marker = layer.selectAll("g")
                  .data(@collection.map (s) -> s.geojson())
                  .enter().append("svg:g")
                  .attr("transform", @transform)
    path = d3.geo.path()
    marker.append("svg:path")
        .attr("d", path)
        .attr("stroke", '#000000')
        .attr("stroke-weight", "5")
        .on 'click', (d) ->
          console.log "clicked the Segment"
    
    map.on "move", ->
      layer.selectAll("g").attr "transform", (d) =>
        lp = map.locationPoint
          lon: d.geometry.coordinates[0][0]
          lat: d.geometry.coordinates[0][1]
        console.log "translate(#{lp.x}, #{lp.y})"
        return "translate(#{lp.x}, #{lp.y})"
  change: ->
    console.log "change: #{@collection.length}"