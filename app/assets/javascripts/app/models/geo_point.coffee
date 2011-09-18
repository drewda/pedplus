class App.Models.GeoPoint extends Backbone.RelationalModel
  name: 'geo_point'
  relations: [
    type: 'HasMany'
    key: 'geo_point_on_segments'
    relatedModel: 'App.Models.GeoPointOnSegment'
    collectionType: 'App.Collections.GeoPointOnSegments'
    reverseRelation:
      key: 'geo_point'
      includeInJSON: 'id'
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
    # only want one GeoPoint or Segment selected at a time
    @collection.selectNone()
    segments.selectNone()
    
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
    else if location.hash.startsWith('#map/edit/geo_point/connect')
      currentGeoPoint = this
      newSegment = segments.create
        ped_project_id: 0 # TODO: add project association
      ,
        success: -> 
          geo_point_on_segments.create
            geo_point_id: currentGeoPoint.id
            segment_id: newSegment.id
          ,
            success: ->
              geo_point_on_segments.create
                geo_point_id: geo_points.selected()[0].id
                segment_id: newSegment.id
              ,
                success: ->
                  masterRouter.fetchData()
    else
      @select()