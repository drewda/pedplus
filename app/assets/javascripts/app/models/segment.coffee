class App.Models.Segment extends Backbone.RelationalModel
  name: 'segment'
  relations: [
    type: 'HasMany'
    key: 'geo_point_on_segments'
    relatedModel: 'App.Models.GeoPointOnSegment'
    collectionType: 'App.Collections.GeoPointOnSegments'
    reverseRelation:
      key: 'segment'
      includeInJSON: 'id'
  ]
  geo_points: ->
    @get('geo_point_on_segments').map (gpos) => gpos.get 'geo_point'
  geojson: ->
    geojson =
      id: @attributes.id
      type: 'Feature'
      geometry:
        type: "LineString"
        coordinates: [
          [ Number @geo_points()[0].get 'longitude'
            Number @geo_points()[0].get 'latitude' ]
          [ Number @geo_points()[1].get 'longitude'
            Number @geo_points()[1].get 'latitude' ]
        ]
  select: ->
    # only want one GeoPoint or Segment selected at a time
    @collection.selectNone()
    geo_points.selectNone()
    
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