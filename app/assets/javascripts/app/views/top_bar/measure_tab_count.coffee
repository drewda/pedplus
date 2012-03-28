class App.Views.MeasureTabCount extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @countPlan = masterRouter.count_plans.getCurrentCountPlan()

    @topBar.render 'measure'
    
    @render()
  template: JST["app/templates/top_bar/measure_tab_count"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template
      project: @options.projects.getCurrentProject()
      users: @options.users
      countPlan: @countPlan
      gateGroupSchedule: @countPlan.getGateGroupSchedule()