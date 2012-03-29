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

      masterRouter.navigate # TODO

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
    else if masterRouter.currentRouteName.startsWith "measureCountScheduleDateUserId"
      $('#tab-area').empty().html @measureTabCountTemplate
        project: @options.projects.getCurrentProject()
        users: masterRouter.users
        countPlan: @countPlan

      # set the appropriate date in the drop-down select

      # set 

      # bindings for drop-down selects
      $('#measure-count-day-select').on "change", $.proxy @measureCountDaySelectChange, this
      $('#measure-count-user-select').on "change", $.proxy @measureCountUserSelectChange, this

    # select today
    # If today's date in not in the CountPlan, the CountPlan's first day
    # will remain selected.
    $('#measure-count-day-select').val new XDate().toString("yyyy-MM-dd")

    # select current user
    $('#measure-count-user-select').val masterRouter.users.getCurrentUser().id

  measureCountDaySelectChange: ->
    date = $('#measure-count-day-select').val()

  measureCountUserSelectChange: ->
    userId = $('#measure-count-user-select').val()