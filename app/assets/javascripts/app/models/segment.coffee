class App.Models.Segment extends Backbone.Model
  name: 'segment'
  getGeoPointOnSegments: ->
    _.compact masterRouter.geo_point_on_segments.select (gpos) =>
      if gpos.isNew()
        return gpos.get('segment_cid') == @cid
      else if gpos.get('markedForDelete')
        return null
      else
        return gpos.get('segment_id') == @id
    , this
  getGeoPoints: ->
    _.map @getGeoPointOnSegments(), (gpos) =>
      gpos.getGeoPoint() unless gpos.get('markedForDelete')
  geojson: ->
    if @getGeoPoints()?.length == 2
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
    masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map/segment/#{@cid}", true)
    $("#segment-line-#{@cid}").svg().addClass('selected').attr("stroke-width", "9")
    @collection.trigger "selection"
  deselect: ->
    @selected = false
    $("#segment-line-#{@cid}").svg().removeClass('selected').attr("stroke-width", "5")
    @collection.trigger "selection"
  toggle: ->
    if @selected
      @deselect()
    else
      @select()