class App.Views.GeoPointLayer extends Backbone.View
  initialize: ->
    @render()
    @geo_points = @options.geo_points
    @geo_points.bind 'reset', @render, this
    @geo_points.bind 'add', @render, this
    @geo_points.bind 'remove', @remove, this
    @geo_points.bind 'change', @remove, this
  drawFeatures: (e) ->
    for f in e.features
      c = f.element
      g = f.element = po.svg("g")
    
      c.setAttribute "class", "geo-point-circle"
      c.setAttribute "id", "geo-point-circle-#{f.data.cid}"
      if masterRouter.geo_points.getByCid(f.data.cid).selected
        c.setAttribute "r", "12"
        if location.hash.startsWith('#map/edit/geo_point/connect')
          c.setAttribute "class", "geo-point-circle connected"
        else
          c.setAttribute "class", "geo-point-circle selected"
      else
        c.setAttribute "r", "8"
        
      if masterRouter.geo_points.getByCid(f.data.cid).get("markedForDelete")
        $(c).remove()
      else
        $(c).bind "click", (event) ->
           cid = event.currentTarget.id.split('-').pop()
           masterRouter.geo_points.getByCid(cid).toggle()
  render: ->
    $('#geo-point-layer').remove() if $('#geo-point-layer')
    layer = po.geoJson()
              .features(masterRouter.geo_points.map (s) -> s.geojson())
              .id("geo-point-layer")
              .on "load", @drawFeatures   
    map.add(layer)
  add: (model) ->
    # TODO: http://groups.google.com/group/d3-js/browse_thread/thread/b2009ed9afc05974
  remove: (model) ->
    $("#geo-point-circle-#{model.cid}").remove()