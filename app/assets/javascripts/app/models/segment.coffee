class App.Models.Segment extends Backbone.Model
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
    else if masterRouter.currentRouteName.startsWith "measure"
      if masterRouter.currentRouteName.startsWith "measureCountEnterCountSession"
        return # we do not want to allow selected when at the "measureCountEnterCountSession" route
      else if masterRouter.currentRouteName.startsWith "measurePlanEditGateGroup"
        # make sure we aren't selecting an already selected gate
        return if @get "gateGroupLabel"
        # when selecting the gates in a GateGroup, we want a maximum of 5 segments selected
        if @collection.selected().length < 5
          @doSelect(true)
        else
          return
      else if masterRouter.currentRouteName.startsWith "measureView"
        masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/measure/view/segment/#{@cid}", true)
        @doSelect()
  doSelect: (allowMultiple) ->
    unless allowMultiple
      # only want one GeoPoint or Segment selected at a time
      @collection.selectNone()
      masterRouter.geo_points.selectNone()
    @set
       selected: true

    # if the user is editing a GateGroup, then we want the selected segment(s) to have the appropriate color
    if masterRouter.currentRouteName.startsWith "measurePlanEditGateGroup"
      gateGroupCid = masterRouter.currentRouteName.split(':')[1]
      gateGroupLabel = masterRouter.gate_groups.getByCid(gateGroupCid).get 'label'
      $("#segment-line-#{@cid}").svg()
        .removeClass()
        .addClass("gateGroup#{gateGroupLabel}")
    # otherwise, on all other tabs, we want the selected segment(s) to have the standard green color
    else
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
    else if masterRouter.currentRouteName.startsWith "measure"
      if masterRouter.currentRouteName.startsWith "measureViewSelectedSegment" or
         masterRouter.currentRouteName.startsWith "measureViewSelectedCountSession"
        # note that we do not want to allow selected when at the "measureEnterCountSession" route
        masterRouter.navigate("#project/#{masterRouter.projects.getCurrentProjectId()}/measure/view", true)
        @doDeselect()
      else if masterRouter.currentRouteName.startsWith "measurePlanEditGateGroup"
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
      $("#segment-line-#{@cid}").svg()
        .removeClass('selected gateGroupA gateGroupB gateGroupC gateGroupD gateGroupE gateGroupF gateGroupG gateGroupH gateGroupI gateGroupJ gateGroupK gateGroupL gateGroupM gateGroupN gateGroupO gateGroupP gateGroupQ  gateGroupR  gateGroupS  gateGroupT')
        .attr "stroke-width", masterRouter.segment_layer.segmentDefaultStrokeWidth

    if masterRouter.currentRouteName.startsWith "measureViewSelectedSegment" or
       masterRouter.currentRouteName.startsWith "measureViewSelectedCountSession"
      $("#segment-line-#{@cid}").svg().addClass "blue" + @get('measuredClass')
    else if masterRouter.currentRouteName.startsWith "measurePlanEditGateGroup"
      $("#segment-line-#{@cid}").svg().addClass "black"
  toggle: ->
    if @get 'selected'
      @deselect()
    else
      @select()

  getCountSessions: ->
    masterRouter.count_sessions.select (cs) -> 
      cs.get('segment_id') == @id
    , this

  totalCounted: ->
    countSessions = 
    _.reduce @getCountSessions(), (memo, cs) ->
      memo + cs.get('counts_count')
    , 0