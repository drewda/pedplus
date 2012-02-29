class App.Views.MeasureTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    @mode = @options.mode

    @modelJob = null
    @modelJobRunningModal = null
    @numberOfCountingLocations = null
    
    @renderData =
      project: @options.projects.getCurrentProject()
      users: @options.users
      segmentId: @options.segmentId
      mode: @mode

    @topBar.render 'measure'
    
#     if @mode == "enterCountSession"
#       @countSession = masterRouter.count_sessions.get @options.countSessionId
      
#       # initialize the array that will hold timestamps for the counts
#       # in the future this may be a few arrays, one for each class of count
#       # like male, female, etc.
#       @countSessionDates = []
    
#       @minutes = 5
#       @millisecondsTotal = @minutes * 60 * 1000
#       @millisecondsRemaining = @millisecondsTotal
#       @endTime = null
#     else
#       # TODO: cache this computation by version number
#       masterRouter.segments.each (s) =>
#         s.set
#           measuredClass: 0 # reset the coloring
#       countTotals = masterRouter.count_sessions.pluck('counts_count')
#       min = _.min countTotals
#       max = _.max countTotals
#       fullRange = max - min
#       classRange = fullRange / 5
#       breaks = [min, min + classRange, min + classRange * 2, min + classRange * 3, min + classRange * 2, max]
#       masterRouter.count_sessions.each (cs) =>
#         value = cs.get('counts_count')
#         for i in [1..breaks.length]
#           if value <= breaks[i]
#             b = i
#             break
#         masterRouter.segments.get(cs.get('segment_id')).set
#           measuredClass: b    
#       # reloading SegmentLayer will draw the coloring
#       masterRouter.segment_layer.layer.reload()
    
    @render()
  template: JST["app/templates/top_bar/measure_tab"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template @renderData

    # enable the appropriate sub tab
    if @mode.startsWith "measurePlan"
      $('#plan-sub-tab').addClass "active"
    else if @mode.startsWith "measureCount"
      $('#count-sub-tab').addClass "active"
    else if @mode.startsWith "measureView"
      $('#view-sub-tab').addClass "active"

    # MEASURE PLAN
    if @mode == "measurePlan"
      $('#count-planning-assistant-button').bind "click", (event) ->
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
    
    # MEASURE PLAN ASSISTANT
    else if @mode == "measurePlanAssistant"
      # measure plan assistant should be modal-style
      # (without main tab menu or sub tab menu)
      $('#top-bar-tabs').remove() 
      $('#measure-sub-tabs').remove()

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
      $('#counting-locations-input').val numberOfUsers * 5

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
      $('#counting-locations-input').change @recomputeCountPlan

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
    numberOfUsers = $('.user-checkbox:checked').length
    numberOfCountLocations = numberOfUsers * 5
    masterRouter.measureTab.numberOfCountLocations = numberOfUsers * 5
    $('#counting-locations-input').val numberOfCountLocations

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
      name: "New Count Plan"
      project_id: masterRouter.projects.getCurrentProjectId()
      start_date: startDate
      weeks: numberOfWeeks
      number_of_intervening_weeks: 0
      days: days.join ','
      hours: hours.join ','
      users: users.join ','
      segments: segments.join ','
    , 
      success: (model) ->
        masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan", true
      , this
      error: (model) ->
        alert 'Error saving your count plan to the server.'
      
#     if @options.mode == "enterCountSession"
#       # don't show the pills to navigate to other modes
#       $('#top-bar .pills').remove()
            
#       @countSession.set
#         start: new Date
      
#       # set the end time
#       @endTime = new Date();
#       @endTime.setMinutes(@endTime.getMinutes() + @minutes)
#       # @endTime.setSeconds(@endTime.getSeconds() + 30)
      
#       # setTimeout =>
#       #   masterRouter.measureTab.finish()
#       # , @millisecondsTotal
#       timer = setInterval =>
#         now = new Date
#         if now > @endTime
#           clearInterval timer
#           masterRouter.measureTab.finish()
#         masterRouter.measureTab.redrawTimer()
#       , 1000 # run every minute
      
#       # plusOneBeep = new Audio "/media/audio/plus_one_beep.mp3"
#       # plusTwoBeep = new Audio "/media/audio/plus_two_beep.mp3"
#       # minusOneBeep = new Audio "/media/audio/minus_one_beep.mp3"
      
#       $('#stop-count-session-cancel-button').on "click", $.proxy =>
#         @countSessionDates = []
#         @countSession.destroy
#           success: (countSession) ->
#             masterRouter.count_sessions.remove countSession
#             masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/segment/#{masterRouter.segments.selected()[0].cid}", true
#       , this
        
#       $('#count-plus-one-button').on "click", $.proxy =>
#         @countSessionDates.push Date() # add the current datetime to the list
#         @redrawCounter()
#         # plusOneBeep.src = plusOneBeep.src
#         # plusOneBeep.play()
#       , this
      
#       $('#count-plus-five-button').on "click", $.proxy =>
#         for num in [1..5]
#           @countSessionDates.push Date() # add the current datetime to the list
#         @redrawCounter()
#         # plusTwoBeep.src = plusTwoBeep.src
#         # plusTwoBeep.play()
#       , this
      
#       $('#count-minus-one-button').on "click", $.proxy =>
#         @countSessionDates.pop()
#         @redrawCounter()
#         # minusOneBeep.src = minusOneBeep.src
#         # minusOneBeep.play()
#       , this
#   redrawCounter: ->
#     $('#counter').html "#{@countSessionDates.length} <h6>people</h6>"
#   redrawTimer: ->
#     @millisecondsRemaining = @millisecondsRemaining - 1000
#     minutes = Math.floor (@millisecondsRemaining / (60 * 1000))
#     seconds = (@millisecondsRemaining % (60 * 1000)) / 1000
#     $('#timer #minutes').html "#{minutes} minutes"
#     $('#timer #seconds').html "#{seconds} seconds"
#   finish: ->
#     masterRouter.clearTimers()
#     countSession = masterRouter.count_sessions.selected()[0]
#     countSession.set
#       stop: new Date
#     _.each @countSessionDates, (cdt) ->
#       count = new App.Models.Count
#       count.set
#         count_session_id: countSession.id
#         at: cdt
#       countSession.counts.add count
#     countSession.uploadCounts
#       success: ->
#         masterRouter.count_sessions.fetch()
#         masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count_session/#{masterRouter.count_sessions.selected()[0].id}", true