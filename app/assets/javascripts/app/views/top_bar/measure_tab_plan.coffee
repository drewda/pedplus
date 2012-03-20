class App.Views.MeasureTabPlan extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @countPlan = masterRouter.count_plans.getCurrentCountPlan()

    @renderData =
      project: @options.projects.getCurrentProject()
      users: @options.users
      countPlan: @countPlan
      segmentId: @options.segmentId

    @topBar.render 'measure'
    
    @render()
  template: JST["app/templates/top_bar/measure_tab_plan"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template @renderData

    $('#count-planning-assistant-button').bind "click", (event) ->
      masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan/assistant", true

    $('#manage-count-plans-button').bind "click", (event) ->
      manageCountPlansModal = new App.Views.ManageCountPlansModal
        archivedCountPlans: masterRouter.count_plans.getArchivedCountPlans()
        currentCountPlan: masterRouter.count_plans.getCurrentCountPlan()