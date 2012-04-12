class Smartphone.Views.StartCountPage extends Backbone.View
  el: '#start-count-page'
  initialize: ->
    @gate = @options.gate
    $('.header-gate-label-span').text @gate.printLabel()

    $('#start-count-yes-button').on "click touchstart", $.proxy @startCountYesButtonClick, this

    masterRouter.map = new Smartphone.Views.Map

    geojson = []
    geojson.push @gate.getSegment().geojson()

    masterRouter.segment_layer = new Smartphone.Views.SegmentLayer
      geojson: geojson
      segmentDefaultStrokeWidth: 10
      segmentSelectedStrokeWidth: 10

    masterRouter.segment_layer.render()
    # TODO: zoom to the segment extent
    masterRouter.map.map.center
      lat: @gate.getSegment().get('start_latitude')
      lon: @gate.getSegment().get('start_longitude')
    masterRouter.map.map.zoom 16

  startCountYesButtonClick: ->
    projectId = masterRouter.projects.getCurrentProjectId()

    # create CountSession locally
    countSession = new Smartphone.Models.CountSession
    countSession.set
      user_id: masterRouter.users.getCurrentUser().id
      project_id: projectId
      gate_id: @gate.id
      count_plan_id: masterRouter.count_plans.getCurrentCountPlan().id
      duration_seconds: masterRouter.count_plans.getCurrentCountPlan().get 'count_session_duration_seconds'
    masterRouter.count_sessions.add countSession

    # select this CountSession so that we'll be able 
    # to access from masterRouter.count_sessions.selected()
    countSession.select()

    # advance to EnterCount
    window.location = "/smartphone#enter-count?projectId=#{projectId}&countSessionCid=#{countSession.cid}"