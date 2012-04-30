class App.Views.MeasureTabPlanEdit extends Backbone.View
  initialize: ->
    # render the top bar
    @topBar = @options.topBar
    @topBar.render 'measure', false

    gateGroupTableRows = []

    @countPlan = masterRouter.count_plans.getByCid @options.countPlanCid
    if masterRouter.currentRouteName.startsWith "measurePlanEditGateGroup"
      @gateGroupCidCurrentlyEditing = @options.gateGroupCid
    else
      @gateGroupCidCurrentlyEditing = null

    # if no GateGroup's exist yet, create the first one
    if @countPlan.getGateGroups().length == 0
      @addGateGroupButton() 

    # otherwise proceed here
    else
      # render the tab
      @render()

      # now render all the GateGroupTableRow's
      _.each @countPlan.getGateGroups(), (gg) ->
        if gg.cid == @gateGroupCidCurrentlyEditing
          mode = "edit"
        else
          mode = "show"
        gateGroupTableRow = new App.Views.GateGroupTableRow
          gateGroup: gg
          mode: mode
        gateGroupTableRows.push gateGroupTableRow
      , this
      # and if there is a row being edited
      if @gateGroupCidCurrentlyEditing
        # remove all the buttons to edit other GateGroup's
        $('.edit-gate-group-button').remove()
        # scroll the table to the row being edited
        $('.modal-body').scrollTo $('.currently-editing')

  template: JST["app/templates/top_bar/measure_tab_plan_edit"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template
      project: @options.projects.getCurrentProject()
      users: masterRouter.users
      countPlan: @countPlan
      currentRouteName: masterRouter.currentRouteName

    # set up start date input fields
    # just put in the CountPlan's year
    year = XDate(@countPlan.get('start_date')).getFullYear()
    $('#start-date-year-input').append $("<option></option>").attr("value", year).text(year)
    if temporary_year = @countPlan.get 'temporary_year'
      $('#start-date-year-input').val temporary_year
    else  
      $('#start-date-year-input').val year
    # put in all the months
    for monthNumber in [1..12]
      fullMonthName = XDate.locales[''].monthNames[monthNumber - 1]
      option = $("<option></option>").attr("value", monthNumber).text(fullMonthName)
      $('#start-date-month-input').append option
    # and now select the CountPlan's month
    # note that XDate's month indices are off by 1
    if temporary_month = @countPlan.get 'temporary_month'
      $('#start-date-month-input').val temporary_month
    else
      month = XDate(@countPlan.get('start_date')).getMonth() + 1
      $('#start-date-month-input').val month
    # put in all the Mondays
    @computeMondayDays()
    # set the day from the CountPlan
    if temporary_day = @countPlan.get 'temporary_day'
      $('#start-date-day-input').val temporary_day
    else
      $('#start-date-day-input').val XDate(@countPlan.get('start_date')).getDate()

    # bindings for recomputing Mondays
    $('#start-date-year-input').change @computeMondayDays
    $('#start-date-month-input').change @computeMondayDays

    # set the number of weeks
    if temporary_weeks = @countPlan.get 'temporary_weeks'
      $('#weeks-input').val temporary_weeks
    else
      $('#weeks-input').val @countPlan.get 'total_weeks'
    # bindings for changing the label for weeks
    $('#weeks-input').change @changeWeeksLabel

    # bindings for recomputing end date
    $('#start-date-year-input').change @changeEndDate
    $('#start-date-month-input').change @changeEndDate
    $('#start-date-day-input').change @changeEndDate
    $('#weeks-input').change @changeEndDate

    # Bindings to save temporary values for start date and number of weeks.
    # This is important so that we don't lose those values when switching back
    # and forth between editing GateGroup's.
    $('#start-date-year-input').on "change", $.proxy @saveTemporaryStartDateAndWeekValues, this
    $('#start-date-month-input').on "change", $.proxy @saveTemporaryStartDateAndWeekValues, this
    $('#start-date-day-input').on "change", $.proxy @saveTemporaryStartDateAndWeekValues, this
    $('#weeks-input').on "change", $.proxy @saveTemporaryStartDateAndWeekValues, this

    # act on the default form values
    @changeEndDate()
    @changeWeeksLabel()

    # bind actions to buttons
    $('#add-gate-group-button').on "click", @addGateGroupButton
    $('#cancel-button').on "click", @cancelButton
    $('#create-count-plan-button').on "click", $.proxy @createCountPlanButton, this

  createCountPlanButton: ->
    year = $('#start-date-year-input').val()
    month = $('#start-date-month-input').val()
    day = $('#start-date-day-input').val()
    weeks = $('#weeks-input').val()

    # validate that there is at least one week
    if weeks < 1
      bootbox.alert "Count plans must last for at least one week."
      return

    # validate that the start date is in the future
    startDate = new XDate("#{year}-#{month}-#{day}")
    if startDate < XDate().addDays(-1)
      bootbox.alert "Count plans must start today or on a future day. They cannot start in the past."
      return

    # validate that there is at least one GateGroup
    if @countPlan.getGateGroups().length < 1
      bootbox.alert "Count plans must include at least one gate group."
      return

    # remove the temporary values
    @countPlan.unset 'temporary_day'
    @countPlan.unset 'temporary_month'
    @countPlan.unset 'temporary_year'
    @countPlan.unset 'temporary_weeks'

    # upload to Api::CountPlansController
    @countPlan.save
      start_date: "#{year}-#{month}-#{day}"
      total_weeks: weeks
      gateGroups: @countPlan.getGateGroups()
      gates: @countPlan.getGates()
    ,
      success: (model, response) ->
        # if upload succeeded, clear the local collections
        masterRouter.count_plans.reset()
        masterRouter.gate_groups.reset()
        masterRouter.gates.reset()
        # and reload the local collections
        masterRouter.count_plans.fetch
          success: ->
            # this will trigger gate_groups and gates to re-fetch()
            # finally redirect to view the count plan
            masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan", true
      error: (model, response) ->
        alert 'Error uploading the count plan to the server. Please restart.'

  addGateGroupButton: (event) ->
    countPlan = masterRouter.count_plans.getCurrentCountPlan()
    # create the new GateGroup with default values
    newGateGroup = countPlan.addNewGateGroup()
    # navigate to the view to edit the new GateGroup
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan/#{countPlan.cid}/edit/gate_group/#{newGateGroup.cid}", true

  cancelButton: (event) ->
    countPlan = masterRouter.count_plans.getCurrentCountPlan()
    # if this is a new plan, then we'll remove all its local entries,
    # and then return the user to the view tab
    if countPlan.isNew()
      # destroy all its GateGroup's
      _.each countPlan.getGateGroups(), (gg) ->
        masterRouter.gate_groups.remove gg
      # now remove the CountPlan
      masterRouter.count_plans.remove countPlan
      # and now we can take the user back to the view subtab
      masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/view", true
    # or if the user has been editing an existing plan, we'll just reset the
    # local records and take them back to viewing the plan
    else
      # remove all local records
      masterRouter.count_plans.reset()
      masterRouter.gate_groups.reset()
      masterRouter.gates.reset()
      # pull data again from the server
      masterRouter.count_plans.fetch
        success: ->
          masterRouter.gate_groups.fetch
            success: ->
              masterRouter.gates.fetch
                success: ->
                  # and now we can return to just viewing the plan
                  masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan", true

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

  saveTemporaryStartDateAndWeekValues: ->
    year = $('#start-date-year-input').val()
    month = $('#start-date-month-input').val()
    day = $('#start-date-day-input').val()
    weeks = $('#weeks-input').val()

    @countPlan.set
      temporary_year: year
      temporary_month: month
      temporary_day: day
      temporary_weeks: weeks