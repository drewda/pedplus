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
  connectedGeoPoints: ->
    connectedGeoPoints = []
    _.each @segments(), (s) =>
      _.each s.geo_points(), (gp) =>
        connectedGeoPoints.push(gp) if gp != this
    return connectedGeoPoints
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
    $("#geo-point-circle-#{@id}").svg().addClass("selected").attr("r", "12")
    @collection.trigger "selection"
  deselect: ->
    @selected = false
    $("#geo-point-circle-#{@id}").svg().removeClass("selected").attr("r", "8")
    @collection.trigger "selection"
  toggle: ->
    if location.hash.startsWith '#map/edit/geo_point/connect'
      if geo_points.selected()[0] == this
        masterRouter.navigate("map/edit", true)
      else
        @drawSegmentToGeoPoint geo_points.selected()[0]
    else if @selected and location.hash.startsWith '#map/edit'
      masterRouter.navigate("map/edit/geo_point/connect/#{@id}", true)
    else if @selected
      @deselect()
    else
      @select()
  drawSegmentToGeoPoint: (targetGeoPoint) ->
    console.log "drawSegmentToGeoPoint: #{targetGeoPoint.id} -- #{this.id} -- #{_.include @connectedGeoPoints(), targetGeoPoint}"
    currentGeoPoint = this
    
    # check to see if this connection already exists
    if not _.include currentGeoPoint.connectedGeoPoints(), targetGeoPoint
      # create the Segment and the two GeoPointOnSegment's
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
                geo_point_id: targetGeoPoint.id
                segment_id: newSegment.id
              ,
                success: ->
                  masterRouter.fetchData
                    success: ->
                      geo_points.get(targetGeoPoint.id).toggle()