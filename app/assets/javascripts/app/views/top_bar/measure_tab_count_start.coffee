class App.Views.MeasureTabCountStart extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @gate = masterRouter.gates.get @options.gateId


    @topBar.render 'measure', false
    @render()
  template: JST["app/templates/top_bar/measure_tab_count_start"]
  render: ->
    $('#tab-area').empty().html @template
      project: @options.projects.getCurrentProject()
      users: masterRouter.users
      gate: @gate

    # button bindings
    $('#cancel-button').on "click", $.proxy @cancelButtonClick, this
    $('#yes-button').on "click", $.proxy @yesButtonClick, this

  cancelButtonClick: ->
    # return to MeasureTabCountSchedule
    window.history.back()

  yesButtonClick: ->
    # create CountSession locally
    countSession = new App.Models.CountSession
    countSession.set
      user_id: masterRouter.users.getCurrentUser().id
      project_id: masterRouter.projects.getCurrentProjectId()
      gate_id: @gate.id
      count_plan_id: masterRouter.count_plans.getCurrentCountPlan().id
      duration_seconds: masterRouter.count_plans.getCurrentCountPlan().get 'count_session_duration_seconds'
    masterRouter.count_sessions.add countSession
    # select this CountSession so that we'll be able 
    # to access from masterRouter.count_sessions.selected()
    countSession.select()

    # advance to MeasureTabCountEnter
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count/enter/count_session/#{countSession.cid}", true