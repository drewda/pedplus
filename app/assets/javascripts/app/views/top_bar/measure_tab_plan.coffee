class App.Views.MeasureTabPlan extends Backbone.View
  initialize: ->
    # render the top bar
    @topBar = @options.topBar
    @topBar.render 'measure'

    # get ready to render CountPlanTableRow's
    @countPlanTableRows = []

    # select the current CountPlan or prepare to create a new one
    @countPlan = masterRouter.count_plans.getCurrentCountPlan()
    if @countPlan
      # set mode so that the proper part of the template is rendered
      @mode = "show"
    else
      # set mode so that the proper part of the template is rendered
      @mode = "new"
      # create the new CountPlan record, just locally for now
      # with the default values
      @countPlan = new App.Models.CountPlan
        project_id: masterRouter.projects.getCurrentProjectId()
        total_weeks: 1
        count_session_duration_seconds: 10 * 60 # 10 minutes
        # start date will be set in view to the next Monday
      # add the local CountPlan to the collection
      masterRouter.count_plans.add @countPlan
      # and add an initial GateGroup, with default values
      @countPlan.addNewGateGroup()
    
    @render()
  template: JST["app/templates/top_bar/measure_tab_plan"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template
      project: @options.projects.getCurrentProject()
      users: @options.users
      countPlan: @countPlan
      segmentId: @options.segmentId
      mode: @mode

    # SHOW
    if @mode == "show"
      console.log 'show'

    # NEW
    else if @mode == "new"
      # set up start date input fields
      # set the current year
      year = XDate().getFullYear()
      $('#start-date-year-input').append $("<option></option>").attr("value", year).text(year)
      for monthNumber in [1..12]
        fullMonthName = XDate.locales[''].monthNames[monthNumber - 1]
        option = $("<option></option>").attr("value", monthNumber).text(fullMonthName)
        option.prop("selected", true) if monthNumber == XDate().getMonth() + 1 # select the current month
        $('#start-date-month-input').append option
      @computeMondayDays()
      # set the next Monday
      mondays = $('#start-date-day-input').children().map ->
        $(this).val()
      for day in mondays.get()
        if day >= XDate().getDate()
          $('#start-date-day-input').val(day)
          break

      # bindings for recomputing Mondays
      $('#start-date-year-input').change @computeMondayDays
      $('#start-date-month-input').change @computeMondayDays

      # set the number of weeks
      $('#weeks-input').val(1)
      # bindings for changing the label for weeks
      $('#weeks-input').change @changeWeeksLabel

      # bindings for recomputing end date
      $('#start-date-year-input').change @changeEndDate
      $('#start-date-month-input').change @changeEndDate
      $('#start-date-day-input').change @changeEndDate
      $('#weeks-input').change @changeEndDate

      # act on the default form values
      @changeEndDate()
      @changeWeeksLabel()

      # render the initial CountPlanTableRow
      @countPlanTableRows.push new App.Views.CountPlanTableRow
        gateGroup: @countPlan.getGateGroups().pop()
        mode: 'new'

    # EDIT
    else if @mode == "edit"
      console.log 'edit'

    # render the CountPlanTableRow's ????

  changeWeeksLabel: ->
    numberOfWeeks = $('#weeks-input').val()
    # display either "weeks" or "week"
    if numberOfWeeks > 1
      $('#weeks-span').text 'weeks'
    else
      $('#weeks-span').text 'week'

  changeEndDate: ->
    numberOfWeeks = $('#weeks-input').val()
    startDate = new XDate $('#start-date-year-input').val() + ' ' + 
                          $('#start-date-month-input').val() + ' ' + 
                          $('#start-date-day-input').val()
    endDate = startDate.addWeeks numberOfWeeks
    endDate = startDate.addDays 6
    $('#end-date-span').text endDate.toString "d MMMM yyyy"

  computeMondayDays: ->
    # clear the current day options
    $('#start-date-day-input').empty()

    # take the first day of the selected month, in the selected year
    year = $('#start-date-year-input').val()
    month = $('#start-date-month-input').val()
    firstDayOfMonth = new XDate "#{year} #{month} 1"

    # find first Monday
    firstMonday = firstDayOfMonth.clone()
    until firstMonday.getDay() == 1
      firstMonday.addDays(1)

    # find rest of Mondays
    mondays = []
    nextMonday = firstMonday.clone()
    while nextMonday.getMonth() == firstMonday.getMonth()
      mondays.push nextMonday.getDate()
      nextMonday = nextMonday.addWeeks(1)

    # render the options
    _.each mondays, (day) ->
      $('#start-date-day-input').append $("<option></option>").attr("value", day).text(day)