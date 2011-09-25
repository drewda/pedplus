class App.Models.GeoPoint extends Backbone.Model
  name: 'geo_point'
  getGeoPointOnSegments: ->
    masterRouter.geoPointOnSegments.select (gpos) =>
      gpos.get('geo_point_cid') == @cid or gpos.get('geo_point_id') == @id
  getSegments: ->
    _.map @getGeoPointOnSegments(), (gpos) =>
      gpos.getSegment()
  geojson: ->
    geojson = 
      id: @attributes.id
      cid: @cid
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
    masterRouter.segments.selectNone()
    
    @selected = true
    masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/#{@cid}", true)
    $("#geo-point-circle-#{@cid}").svg().addClass("selected").attr("r", "12")
    @collection.trigger "selection"
  deselect: ->
    @selected = false
    masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map", true)
    $("#geo-point-circle-#{@cid}").svg().removeClass("selected").attr("r", "8")
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