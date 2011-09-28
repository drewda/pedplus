class App.Models.GeoPoint extends Backbone.Model
  name: 'geo_point'
  getGeoPointOnSegments: ->
    masterRouter.geo_point_on_segments.select (gpos) =>
      if @isNew()
        return gpos.get('geo_point_cid') == @cid
      else 
        return gpos.get('geo_point_id') == @id
    , this
  getSegments: ->
    _.compact _.map @getGeoPointOnSegments(), (gpos) =>
      gpos.getSegment() unless gpos.get('markedForDelete')
  getConnectedGeoPoints: ->
    _.compact _.map @getSegments(), (s) =>
      s.getGeoPoints() unless s.get('markedForDelete')
  geojson: ->
    if @get('markedForDelete')
      return null
    else
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
    if location.hash.startsWith "#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/connect/c"
      @drawSegmentToGeoPoint masterRouter.geo_points.selected()[0]
    else if location.hash.startsWith "#project/#{masterRouter.projects.getCurrentProjectId()}/map" or 
            location.hash.startsWith "#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/#{@cid}" 
      # only want one GeoPoint or Segment selected at a time
      @collection.selectNone()
      masterRouter.segments.selectNone()

      @selected = true
      
      masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/#{@cid}", true)
      $("#geo-point-circle-#{@cid}").svg().addClass("selected").attr("r", "12")
    
  deselect: ->
    if location.hash.startsWith "#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/connect/c"
      masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/#{@cid}", true)
      $("#geo-point-circle-#{@cid}").svg().addClass("selected").attr("r", "12")
    else if location.hash.startsWith "#project/#{masterRouter.projects.getCurrentProjectId()}/map" or
            location.hash.startsWith "#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/#{cid}" 
      masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map", true)
      $("#geo-point-circle-#{@cid}").svg().removeClass("selected").attr("r", "8")
      @selected = false
      
  toggle: ->
    if @selected
      @deselect()
    else
      @select()
  drawSegmentToGeoPoint: (targetGeoPoint) ->
    console.log "drawSegmentToGeoPoint: #{targetGeoPoint.cid} -- #{this.cid}"
    currentGeoPoint = this
    
    # check to see if this connection already exists
    if not _.include currentGeoPoint.getConnectedGeoPoints(), targetGeoPoint # TODO: fix this!
      mapEdit = new App.Models.MapEdit
      masterRouter.map_edits.add mapEdit
      # create the Segment
      newSegment = new App.Models.Segment
        project_id: masterRouter.projects.getCurrentProjectId()
      mapEdit.set
        segments: [newSegment]
      # create the first GeoPointOnSegment
      if currentGeoPoint.isNew()
        gposCurrentGeoPoint = new App.Models.GeoPointOnSegment
          geo_point_cid: currentGeoPoint.cid
          segment_cid: newSegment.cid
          project_id: masterRouter.projects.getCurrentProjectId()
      else
        gposCurrentGeoPoint = new App.Models.GeoPointOnSegment
          geo_point_id: currentGeoPoint.id
          segment_cid: newSegment.cid
          project_id: masterRouter.projects.getCurrentProjectId()
      # create the second GeoPointOnSegment
      if targetGeoPoint.isNew()
        gposTargetGeoPoint = new App.Models.GeoPointOnSegment
          geo_point_cid: targetGeoPoint.cid
          segment_cid: newSegment.cid
          project_id: masterRouter.projects.getCurrentProjectId()
      else
        gposTargetGeoPoint = new App.Models.GeoPointOnSegment
          geo_point_id: targetGeoPoint.id
          segment_cid: newSegment.cid
          project_id: masterRouter.projects.getCurrentProjectId()
      mapEdit.set
        geo_point_on_segments: [gposCurrentGeoPoint, gposTargetGeoPoint]
      
      masterRouter.geo_point_on_segments.add gposCurrentGeoPoint
      masterRouter.geo_point_on_segments.add gposTargetGeoPoint
      masterRouter.segments.add newSegment