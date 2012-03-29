class App.Views.MeasureTabCount extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @countPlan = masterRouter.count_plans.getCurrentCountPlan()

    # if we're in the measureCountScheduleDateUserId route,
    # we have a date and a userId specified
    @date = @options.date
    @userId = @options.userId

    # if there a CountPlan exists, but no date or userId has been specified
    # we'll show today (or the first date of the CountPlan) and this user
    # (or the first user listed on the CountPlan)
    if @countPlan and (not @date) and (not @userId)
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
    @topBar.render 'measure'
    @render()
  measureTabCountTemplate: JST["app/templates/top_bar/measure_tab_count"]
  measureTabCountScheduleTemplate: JST["app/templates/top_bar/measure_tab_count_schedule"]
  render: ->
    # the small version of MeasureTabCount, which just has the instructions
    # for the user to create a CountPlan
    if masterRouter.currentRouteName.split(':')[0] == "measureCount"
      # render the template
      $('#tab-area').empty().html @measureTabCountTemplate
        project: @options.projects.getCurrentProject()

    # the full-fledged schedule
    else if masterRouter.currentRouteName.startsWith "measureCountScheduleDateUser"
      $('#tab-area').empty().html @measureTabCountTemplate
        project: @options.projects.getCurrentProject()
        users: masterRouter.users
        countPlan: @countPlan

      # set the appropriate date in the drop-down select
      $('#measure-count-day-select').val @date

      # set the appropriate user in the drop-down select
      $('#measure-count-user-select').val @userId

      # bindings for drop-down selects
      $('#measure-count-day-select').on "change", $.proxy @measureCountDaySelectChange, this
      $('#measure-count-user-select').on "change", $.proxy @measureCountUserSelectChange, this

  measureCountDaySelectChange: ->
    date = $('#measure-count-day-select').val()
    masterRouter.navigate 

  measureCountUserSelectChange: ->
    userId = $('#measure-count-user-select').val()