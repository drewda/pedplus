class Smartphone.Models.Segment extends Backbone.Model
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
    if @get('markedForDelete') 
      return null
    else # if @getGeoPoints()?.length == 2
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
  select: ->
    if masterRouter.currentRouteName.startsWith "map"
      if masterRouter.currentRouteName.startsWith "mapConnectGeoPoint"
        return
      else
        masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map/segment/#{@cid}", true)
        @doSelect()
    else if masterRouter.currentRouteName == "measure" or
            masterRouter.currentRouteName.startsWith "measureSelectedSegment" or
            masterRouter.currentRouteName.startsWith "measureSelectedCountSession"
      # note that we do not want to allow selected when at the "measureEnterCountSession" route
      masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/measure/segment/#{@cid}", true)
      @doSelect()
  doSelect: ->
    # only want one GeoPoint or Segment selected at a time
    @collection.selectNone()
    masterRouter.geo_points.selectNone()
    @set
       selected: true
    $("#segment-line-#{@cid}").svg()
      .removeClass('red0 red1 red2 red3 red4 red5 blue0 blue1 blue2 blue3 blue4 blue5')
      .addClass('selected')
  deselect: ->
    if masterRouter.currentRouteName.startsWith "map"
      if masterRouter.currentRouteName == "mapConnectGeoPoint:#{@cid}"
        return null
      else
        masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/map", true)
        @doDeselect()
    else if masterRouter.currentRouteName == "measure" or
            masterRouter.currentRouteName.startsWith "measureSelectedSegment" or
            masterRouter.currentRouteName.startsWith "measureSelectedCountSession"
      # note that we do not want to allow selected when at the "measureEnterCountSession" route
      masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/measure", true)
      @doDeselect()
  doDeselect: ->
    # if this Segment is not already selected, then we want its 
    # @set() command to be silent and not fire a changed event
    alreadySelected = @get('selected')
    @set
      selected: false
    , 
      silent: !alreadySelected
    if alreadySelected
      $("#segment-line-#{@cid}").svg().removeClass('selected').attr "stroke-width", masterRouter.segment_layer.segmentDefaultStrokeWidth
  toggle: ->
    if @get 'selected'
      @deselect()
    else
      @select()