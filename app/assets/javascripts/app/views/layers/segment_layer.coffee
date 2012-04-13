class App.Views.SegmentLayer extends Backbone.View
  initialize: ->
    @segmentDefaultStrokeWidth = @options.segmentDefaultStrokeWidth
    @segmentSelectedStrokeWidth = @options.segmentSelectedStrokeWidth
   
    @segments = @options.segments
    
    @layer = null
  enable: ->
    @segments.bind 'reset',   @render, this
    
    if $('#segment-layer').length == 0
      @render()
  disable: ->
    @segments.unbind()
    @remove()
  remove: ->
    if @layer
      masterRouter.map.map.remove(@layer)
    if $('#segment-layer').length > 0
      $('#segment-layer').remove()
  render: ->
    @remove()
    @layer = po.geoJson()
              .features(@segments.geojson().features)
              .id("segment-layer")
              .tile(false)
              .scale("fixed")
              .on("load", @loadFeatures)
              .on("show", @showFeatures)

                                 
    masterRouter.map.map.add(@layer)
    # reorder the layers: we want SegmentLayer to be under GeoPointLayer
    #                     and we want both to be under the zoom buttons
    $('#osm-color-layer').after($('#segment-layer'))

  loadFeatures: (e) ->
    for f in e.features   
      c = f.element

      c.setAttribute "id", "segment-line-#{f.data.cid}"
      c.setAttribute "stroke-width", masterRouter.segment_layer.segmentDefaultStrokeWidth
      
      if masterRouter.segments.getByCid(f.data.cid).get("markedForDelete")? or
        masterRouter.segments.getByCid(f.data.cid).get("moved")? or
         masterRouter.segments.getByCid(f.data.cid).isNew()
        $(c).remove()
      else
        $(c).bind "click", (event) ->
          cid = event.currentTarget.id.split('-').pop()
          masterRouter.segments.getByCid(cid).toggle()

  showFeatures: (e) ->
    connectedSegmentCids = []
    if location.hash.startsWith "#project/#{masterRouter.projects.getCurrentProjectId()}/map/geo_point/connect/c"
      geoPointCid = location.hash.split('/').pop()
      connectedSegmentCids = _.map masterRouter.geo_points.getByCid(geoPointCid).getSegments(), (s) => s.cid

    for f in e.features   
      c = f.element

      c.removeAttribute "class"

      # model tab
      if masterRouter.currentRouteName.startsWith "model"
        if masterRouter.currentRouteName.startsWith "modelPermeability"
          colorClass = masterRouter.segments.getByCid(f.data.cid).get('permeabilityClass')
          c.setAttribute "class", "red#{colorClass}"
        else
          c.setAttribute "class", "segment-line black"

      # measure tab
      else if masterRouter.currentRouteName.startsWith "measure"
        # measure plan subtab
        if masterRouter.currentRouteName.startsWith "measurePlan"
          # set GateGroup colors for the saved gates
          gateGroupLabel = masterRouter.segments.getByCid(f.data.cid).get('gateGroupLabel')
          if gateGroupLabel
            c.setAttribute "class", "gateGroup#{gateGroupLabel} segment-line"
          # and also set the GateGroup colors for currently selected segments,
          # if the user is editing
          else if masterRouter.segments.getByCid(f.data.cid).get("selected")
            gateGroupCid = masterRouter.currentRouteName.split(':')[1]
            gateGroupLabel = masterRouter.gate_groups.getByCid(gateGroupCid).get 'label'
            c.setAttribute "class", "gateGroup#{gateGroupLabel} segment-line"
          else
            c.setAttribute "class", "segment-line black"

        # measure count subtab
        else if masterRouter.currentRouteName.startsWith "measureCount"
          if masterRouter.currentRouteName.startsWith "measureCountScheduleDateUser"
            # pull the date and user ID out of the URL
            date = String(window.location).match(/date\/([\d-]+)/g)[0].replace('date/','')
            userId = Number(String(window.location).split('/').pop())
            # identify all the segments associated with the gates being shown for this date and user
            segmentIds = masterRouter.count_plans.getCurrentCountPlan().getGatesFor(date, userId) # TODO: speed this up, maybe with _.memoize
            # find the current segment
            segment = masterRouter.segments.getByCid(f.data.cid)
            # if the current segment is one of the segments associated with the gates, then show display
            # if not, don't display the segment
            if _.include segmentIds, segment.id
              gateGroupLabel = segment.get('gateGroupLabel')
              c.setAttribute "class", "gateGroup#{gateGroupLabel} segment-line"
          else if masterRouter.currentRouteName.startsWith "measureCountStartGate"
            # only show the segment for the Gate the user may start counting at
            gateId = Number(String(window.location).split('/').pop())
            gate = masterRouter.gates.get(gateId)
            if gate.getSegment().cid == f.data.cid
              c.setAttribute "class", "selected segment-line"
          else if masterRouter.currentRouteName.startsWith "measureCountEnterCountSession"
            # only show the segment for the CountSessions
            countSessionCid = String(window.location).split('/').pop()
            gate = masterRouter.count_sessions.getByCid(countSessionCid).getGate()
            if gate.getSegment().cid == f.data.cid
              c.setAttribute "class", "selected segment-line"

        # measure view subtab
        else if masterRouter.currentRouteName.startsWith "measureView"
          colorClass = masterRouter.segments.getByCid(f.data.cid).get('measuredClass')
          # if f.data.id == selectedSegmentId
          #   c.setAttribute "class", "segment-line selected"
          if colorClass > 0
            c.setAttribute "class", "segment-line blue#{colorClass}"
          else
            c.setAttribute "class", "segment-line black"

          # if masterRouter.currentRouteName.startsWith "measureSelectedCountSession"
          #   selectedCountSessionId = masterRouter.currentRouteName.split(':').pop()
          #   selectedSegmentId = masterRouter.count_sessions.get(selectedCountSessionId).get('segment_id')
          # else if masterRouter.currentRouteName.startsWith "measureSelectedSegment"
          #   selectedSegmentCid = masterRouter.currentRouteName.split(':').pop()
          #   selectedSegmentId = masterRouter.segments.getByCid(selectedSegmentCid).id
      
      # map tab
      else if masterRouter.currentRouteName.startsWith "map"
        # the selected segment
        if masterRouter.segments.getByCid(f.data.cid).get("selected")
          c.setAttribute "class", "segment-line selected black"

        # connected segments
        else if connectedSegmentCids.length > 0
          if _.include connectedSegmentCids, f.data.cid
            c.setAttribute "class", "segment-line connected black"
            connectedSegmentCids = _.without connectedSegmentCids, f.data.id
          else
            c.setAttribute "class", "segment-line black"
        # other segments
        else
          c.setAttribute "class", "segment-line black"

      # project tab
      else if masterRouter.currentRouteName.startsWith "project"
        c.setAttribute "class", "segment-line black"
  
  setSegmentDefaultStrokeWidth: (segmentDefaultStrokeWidth) ->
    @segmentDefaultStrokeWidth = segmentDefaultStrokeWidth
    @render()
  setSegmentSelectedStrokeWidth: (segmentSelectedStrokeWidth) ->
    @segmentSelectedStrokeWidth = segmentSelectedStrokeWidth
    @render()