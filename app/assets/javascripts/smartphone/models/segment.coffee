class Smartphone.Models.Segment extends Backbone.Model
  name: 'segment'
  geojson: ->
    geojson =
      id: @attributes.id
      cid: @cid
      type: 'Feature'
      geometry:
        type: "LineString"
        coordinates: [
          [ Number @get 'start_longitude'
            Number @get 'start_latitude' ]
          [ Number @get 'end_longitude'
            Number @get 'end_latitude' ]
          ]