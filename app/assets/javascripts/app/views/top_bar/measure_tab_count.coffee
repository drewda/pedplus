class App.Views.MeasureTabCount extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @countPlan = masterRouter.count_plans.getCurrentCountPlan()

    # if there a CountPlan exists, we'll show today (or the first date of the CountPlan)
    # and this user (or the first user listed on the CountPlan)
    if @countPlan
      # see if today is in CountPlan's date range
      today = new XDate()
      startDate = new XDate @countPlan.get('start_date')
      endDate = new XDate @countPlan.get('end_date')
      if today >= startDate and today <= endDate
        date = today.toString("yyyy-MM-dd")
      else if today < startDate
        date = startDate.toString("yyyy-MM-dd")
      else
        date = endDate.toString("yyyy-MM-dd")

      # see if current user is in CountPlan
      currentUserId = masterRouter.users.getCurrentUser().id
      if _.include @countPlan.getAllUserIds(), currentUserId
        userId = currentUserId
      else
        userId = @countPlan.getAllUserIds()[0]

      masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count/schedule/date/#{date}/user/#{userId}", true

    # otherwise we'll render the small version of MeasureTabCount,
    # which instruct the user to create a CountPlan
    else
      @topBar.render 'measure'
      @render()
  template: JST["app/templates/top_bar/measure_tab_count"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template
      project: @options.projects.getCurrentProject()