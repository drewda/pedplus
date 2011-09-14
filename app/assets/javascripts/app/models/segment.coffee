class App.Models.Segment extends Backbone.RelationalModel
  name: 'segment'
  relations: [
    type: 'HasMany'
    key: 'geo_point_on_segments'
    relatedModel: 'App.Models.GeoPointOnSegment'
    collectionType: 'App.Collections.GeoPointOnSegments'
    reverseRelation:
      key: 'segment'
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