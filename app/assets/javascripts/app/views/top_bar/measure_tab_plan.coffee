class App.Views.MeasureTabPlan extends Backbone.View
  initialize: ->
    # render the top bar
    @topBar = @options.topBar
    @topBar.render 'measure'

    # get ready to render CountPlanTableRow's
    @countPlanTableRows = []

    # select the current CountPlan
    @countPlan = masterRouter.count_plans.getCurrentCountPlan()
    # or prepare to create a new one locally
    if not @countPlan
      # Create the new CountPlan record with the default values.

      @countPlan = new App.Models.CountPlan
        project_id: masterRouter.projects.getCurrentProjectId()
        total_weeks: 1
        count_session_duration_seconds: 10 * 60 # 10 minutes
        is_the_current_plan: true
        start_date: @nextMonday()
      # add to the CountPlan collection
      masterRouter.count_plans.add @countPlan
      # and now redirect to MeasureTabPlanEdit
      masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan/#{@countPlan.cid}/edit", true

    else
      @render()
  template: JST["app/templates/top_bar/measure_tab_plan"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template
      project: @options.projects.getCurrentProject()
      users: @options.users
      countPlan: @countPlan

  nextMonday: ->
    # start with today
    date = XDate()
    # if today is a Monday, just return today
    return date if date.getDay() == 1
    # or keep adding days until the date is a Monday
    date.addDays(1) until date.getDay() == 1
    return date