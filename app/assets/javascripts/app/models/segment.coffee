class App.Models.Segment extends Backbone.Model
  name: 'segment'
  getGeoPointOnSegments: ->
    masterRouter.geo_point_on_segments.select (gpos) =>
      gpos.get('segment_cid') == @cid or gpos.get('segment_id') == @id
    , this
  getGeoPoints: ->
    _.map @getGeoPointOnSegments(), (gpos) =>
      gpos.getGeoPoint()
  geojson: ->
    geojson =
      id: @attributes.id
      cid: @cid
      type: 'Feature'
      geometry:
        type: "LineString"
        coordinates: [
          [ Number @getGeoPoints()[0].get 'longitude'
            Number @getGeoPoints()[0].get 'latitude' ]
          [ Number @getGeoPoints()[1].get 'longitude'
            Number @getGeoPoints()[1].get 'latitude' ]
        ]
  select: ->
    # only want one GeoPoint or Segment selected at a time
    @collection.selectNone()
    masterRouter.geo_points.selectNone()
    
    @selected = true
    $("#segment-line-#{@id}").svg().addClass('selected').attr("stroke-width", "9")
    @collection.trigger "selection"
  deselect: ->
    @selected = false
    $("#segment-line-#{@id}").svg().removeClass('selected').attr("stroke-width", "5")
    @collection.trigger "selection"
  toggle: ->
    if @selected
      @deselect()
    else
      @select()