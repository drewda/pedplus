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
    _.compact _.flatten _.map @getSegments(), (s) =>
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
    if masterRouter.currentRouteName.startsWith "map"
      if masterRouter.currentRouteName.startsWith "mapConnectGeoPoint" 
        @drawSegmentToGeoPoint masterRouter.geo_points.selected()[0]
      else 
        # only want one GeoPoint or Segment selected at a time
        @collection.selectNone()
        masterRouter.segments.selectNone()
        @set
          selected: true
        masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/#{@cid}", true)
  deselect: ->
    if masterRouter.currentRouteName.startsWith "map"
      if masterRouter.currentRouteName == "mapConnectGeoPoint:#{@cid}"
        masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/#{@cid}", true)
      else
        masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map", true)
        # if this GeoPoint is not already selected, then we want its 
        # @set() command to be silent and not fire a changed event
        alreadySelected = @get('selected')
        @set
          selected: false
        , 
          silent: !alreadySelected
  toggle: ->
    if @get('selected')
      @deselect()
    else
      @select()
  drawSegmentToGeoPoint: (targetGeoPoint) ->
    currentGeoPoint = this
    
    # check to see if this connection already exists
    existingConnections = _.select currentGeoPoint.getConnectedGeoPoints(), (gp) =>
      gp.cid == targetGeoPoint.cid
    if existingConnections.length == 0
      mapEdit = new App.Models.MapEdit
      masterRouter.map_edits.add mapEdit
      # create the Segment
      newSegment = new App.Models.Segment
        project_id: masterRouter.projects.getCurrentProjectId()
        start_longitude: currentGeoPoint.get "longitude"
        start_latitude: currentGeoPoint.get "latitude"
        end_longitude: targetGeoPoint.get "longitude"
        end_latitude: targetGeoPoint.get "latitude"
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