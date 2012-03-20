class App.Views.MeasureTabCount extends Backbone.View
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
  template: JST["app/templates/top_bar/measure_tab_count"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template @renderData