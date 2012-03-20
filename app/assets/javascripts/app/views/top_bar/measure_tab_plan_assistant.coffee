class App.Views.MeasureTabPlanAssistant extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @countPlan = masterRouter.count_plans.getCurrentCountPlan()

    @modelJob = null
    @modelJobRunningModal = null
    @numberOfCountingLocations = null

    # NOTE: turn this off for now because it's slow
    # TODO: this code block should be moved somewhere else (PEDPLUS-70)
    ###
    # check to see if permeability model already exists or if it needs to be run
    if masterRouter.model_jobs.getModelsForCurrentVersion("permeability").length > 0
      # continue on to count planning assistant
      masterRouter.measureTab.continueToCountPlanningAssistant masterRouter.model_jobs.getModelsForCurrentVersion("permeability").pop()
    else
      # run the permeability model first
      masterRouter.measureTab.modelJobRunningModal = bootbox.modal 'Please wait while the server models the accessibility of your project map.'
      masterRouter.spinner.disable()
      masterRouter.model_jobs.create
        project_id: masterRouter.projects.getCurrentProjectId()
        kind: 'permeability'
        project_version: masterRouter.projects.getCurrentProject().get('version')
      , success: (model) ->
          masterRouter.map.enableSegmentWorkingAnimation()
          masterRouter.measureTab.modelJob = model
          @permeabilityPoll = setInterval 'masterRouter.measureTab.pollForPermeability()', 2000
        , this
        error: ->
          alert 'Error starting permeability analysis.'
    ###

    @renderData =
      project: @options.projects.getCurrentProject()
      users: @options.users
      countPlan: @countPlan

    # measure plan assistant should be modal-style (without main tab menu)
    @topBar.render 'measure', false
    
    @render()
  template: JST["app/templates/top_bar/measure_tab_plan_assistant"]

  render: ->
    # render the template
    $('#tab-area').empty().html @template @renderData
    
    ### START###
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

    # set default number of counting locations
    numberOfUsers = $('.user-checkbox:checked').length
#    $('#counting-locations-input').val numberOfUsers * 5

    # more default values
    $('#weeks-input').val(1)
    for dayOfWeek in ['tuesday', 'thursday', 'saturday', 'sunday']
      $("##{dayOfWeek}-checkbox").prop "checked", true
    for hour in [700, 800, 900, 1200, 1300, 1600, 1700, 1800, 1900]
      $("##{hour}-checkbox").prop "checked", true

    # bindings for recomputing Mondays
    $('#start-date-year-input').change @computeMondayDays
    $('#start-date-month-input').change @computeMondayDays

    # bindings for recomputing resources
    $('.user-checkbox').change @recomputeCountPlan
    $('#weeks-input').change @recomputeCountPlan
    $('.day-checkbox').change @recomputeCountPlan
    $('.hour-checkbox').change @recomputeCountPlan
#    $('#counting-locations-input').change @recomputeCountPlan

    # do an initial resource compute
    @recomputeCountPlan()

    $('#create-plan-button').bind "click", (event) ->
      masterRouter.measureTab.createCountPlan()

  pollForPermeability: ->
    @modelJob.fetch
      success: (model) ->
        if model.get('output')
          clearInterval(@permeabilityPoll)
          masterRouter.spinner.enable()
          masterRouter.measureTab.endPermeabilityAnalysis(model.id)
    
  endPermeabilityAnalysis: (modelJobId) ->
    masterRouter.model_jobs.fetch
      success: (modelJob) ->
        masterRouter.map.disableSegmentWorkingAnimation()
        masterRouter.measureTab.modelJobRunningModal.modal 'hide'
        masterRouter.measureTab.continueToCountPlanningAssistant(modelJob)
      , this
      error: ->
        alert 'Error fetching the results of the permeability analysis from the server.'

  continueToCountPlanningAssistant: (modelJob) ->
    # load permeability values
    output = modelJob.get('output') # this is JSON
    outputJson = JSON.parse(output)
    _.each outputJson, (pv) =>
      masterRouter.segments.get(pv.segment_id).set
        permeabilityValue: pv.permeability
        # permeabilityClass: pv.breakNum
    # continue on to count planning assistant
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan/assistant", true

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

  recomputeCountPlan: ->
    numberOfCountLocations = $('#counting-locations-input').val()
    numberOfUsers          = $('.user-checkbox:checked').length
    numberOfWeeks          = $('#weeks-input').val()
    numberOfHours          = $('.hour-checkbox:checked').length
    numberOfDays           = $('.day-checkbox:checked').length
    numberOfCountingDays   = numberOfUsers * numberOfWeeks * numberOfHours * numberOfDays
    numberOfCountingDayCredits = _.sum(masterRouter.users.pluck('counting_day_credits'))

    # clear alert
    $('#measure-plan-assistant-alert').empty().removeClass('alert alert-info alert-error')

    # alert when going over resource limits
    if numberOfCountingDays > numberOfCountingDayCredits
      $('#measure-plan-assistant-alert').addClass("alert alert-error").html "Please contact S3Sol to purchase <strong>#{numberOfCountingDays - numberOfCountingDayCredits}</strong> more counting day credits."
    else
      $('#measure-plan-assistant-alert').html "&nbsp;" # TODO: clean up the positioning of the alert

    # set the number of counting locations to the number of users
    # TODO: allow for more counting locations if there are a sufficient number of hours selected for counting
    # numberOfUsers = $('.user-checkbox:checked').length
    # numberOfCountLocations = numberOfUsers * 5
    masterRouter.measureTab.numberOfCountLocations = numberOfCountLocations
    # $('#counting-locations-input').val numberOfCountLocations

    # NOTE: disable this for now because it's slow
    ###
    # select segments on map
    # unselect all
    masterRouter.segments.selectNone()
    # get the most permeable segments
    segmentsMostToLeastPermeable = _.sortBy masterRouter.segments.models, (s) ->
      s.get 'permeabilityValue' * -1
    numberOfNexuses = numberOfCountLocations / 5
    for num in [0...numberOfNexuses]
      nexusSegment = segmentsMostToLeastPermeable[num]
      masterRouter.measureTab.selectNexus nexusSegment
    ###

  selectNexus: (currentSegment) ->
    if masterRouter.segments.selected().length < @numberOfCountLocations
      currentSegment.select()
      for geoPoint in currentSegment.getGeoPoints()
        for segment in geoPoint.getSegments()
          @selectNexus segment
    else
      return

  createCountPlan: ->
    startDate              = new XDate $('#start-date-year-input').val() + ' ' + 
                                       $('#start-date-month-input').val() + ' ' + 
                                       $('#start-date-day-input').val()
    numberOfCountLocations = $('#counting-locations-input').val()
    numberOfUsers          = $('.user-checkbox:checked').length
    numberOfWeeks          = $('#weeks-input').val()
    numberOfHours          = $('.hour-checkbox:checked').length
    numberOfDays           = $('.day-checkbox:checked').length

    users = []
    $('.user-checkbox:checked').map -> users.push this.value

    days = []
    $('.day-checkbox:checked').map -> days.push this.value

    hours = []
    $('.hour-checkbox:checked').map -> hours.push this.value

    segments = _.pluck masterRouter.segments.selected(), 'id'

    # TODO: form validation
    countPlan = masterRouter.count_plans.create
      project_id: masterRouter.projects.getCurrentProjectId()
      start_date: startDate
      weeks: numberOfWeeks
      intervening_weeks: 0
      days: days.join ','
      hours: hours.join ','
      users: users.join ','
      segments: segments.join ','
      is_the_current_plan: true
    , 
      success: (model) ->
        masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan", true
      , this
      error: (model) ->
        alert 'Error saving your count plan to the server.'