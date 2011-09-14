class App.Models.GeoPoint extends Backbone.RelationalModel
  name: 'geo_point'
  relations: [
    type: 'HasMany'
    key: 'geo_point_on_segments'
    relatedModel: 'App.Models.GeoPointOnSegment'
    collectionType: 'App.Collections.GeoPointOnSegments'
    reverseRelation:
      key: 'geo_point'
  ]
  segments: ->
    @get('geo_point_on_segments').map (gpos) => gpos.get 'segment'
  geojson: ->
    geojson = 
      id: @attributes.id
      type: 'Feature'
      geometry:
        type: "Point"
        coordinates: [
          parseFloat @get "longitude"
          parseFloat @get "latitude"
        ]
  select: ->
    @selected = true
    $("#geo-point-circle-#{@id}").attr("fill", "#55ee33").attr("r", "12")
    @collection.trigger "selection"
  deselect: ->
    @selected = false
    $("#geo-point-circle-#{@id}").attr("fill", "#000000").attr("r", "8")
    @collection.trigger "selection"
  toggle: ->
    if @selected
      @deselect()
    else
      @select()