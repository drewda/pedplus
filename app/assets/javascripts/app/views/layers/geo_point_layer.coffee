class App.Views.GeoPointLayer extends Backbone.View
  initialize: ->
    @geoPointDefaultRadius = @options.geoPointDefaultRadius
    @geoPointSelectedRadius = @options.geoPointSelectedRadius
    
    @geo_points = @options.geo_points
  enable: ->
    @geo_points.bind 'reset',  @change, this
    @geo_points.bind 'change', @change, this
    @geo_points.bind 'add',    @change, this
    @geo_points.bind 'remove', @change, this
    
    if $('#geo-point-layer').length == 0
      @render()
      @change()
  disable: ->
    @geo_points.unbind()
    $('#geo-point-layer').remove()
  render: ->
    layer = d3.select("#map-area svg").insert "svg:g"
    layer.attr "id", "geo-point-layer"

    map.on "move",    @reapplyTransform
    map.on "resize",  @reapplyTransform
  transform: (d) ->
    lp = map.locationPoint
      lon: d.get('longitude')
      lat: d.get('latitude')
    return "translate(#{lp.x}, #{lp.y})"
  reapplyTransform: ->
    d3.select('#geo-point-layer').selectAll("g").attr "transform", masterRouter.geo_point_layer.transform
  change: (geo_point) ->
    # update the bound data
    geo_points = @geo_points.reject (gp) => gp.get('markedForDelete')

    geoPointMarkers = d3.select('#geo-point-layer').selectAll("g")
                        .data geo_points, (d) =>
                          d.cid
              
    # enter new elements          
    geoPointMarkers.enter()
      .append("svg:g")
        .attr("transform", @transform)
      .append("svg:circle")
        .classed 'selected', (d) ->
          d.get 'selected'
        .attr "r", (d) ->
          if d.selected
            masterRouter.geo_point_layer.geoPointSelectedRadius
          # else if connected
          else
            masterRouter.geo_point_layer.geoPointDefaultRadius
        .classed("geo-point-circle", true)
        .attr "id", (d) -> 
          "geo-point-circle-#{d.cid}"
        .on 'click', (d) -> 
          d.toggle()
          
    # if there is a changed GeoPoint, go in and modify it      
    if geo_point and !geo_point.models
      changedGeoPointMarkers = geoPointMarkers.filter (d, i) =>
        d.cid == geo_point.cid
      # select
      changedGeoPointMarkers.selectAll('circle')
        .attr "r", (d) ->
          if d.get 'selected'
            masterRouter.geo_point_layer.geoPointSelectedRadius
          else
            masterRouter.geo_point_layer.geoPointDefaultRadius
        .classed "selected", (d) ->
          d.get 'selected'
      # move
      @reapplyTransform()
      # move segments
      masterRouter.segment_layer.reapplyTransform()
          
    # remove old elements
    geoPointMarkers.exit().remove()

  setGeoPointDefaultRadius: (geoPointDefaultRadius) ->
    @geoPointDefaultRadius = geoPointDefaultRadius
    @render()
  setGeoPointSelectedRadius: (geoPointSelectedRadius) ->
    @geoPointSelectedRadius = geoPointSelectedRadius
    @render()