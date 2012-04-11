class App.Views.MeasureTabCountEnter extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @countSession = masterRouter.count_sessions.getByCid @options.countSessionCid

    # initialize the array that will hold timestamps for the counts
    # in the future this may be a few arrays, one for each class of count
    # like male, female, etc.
    @countSessionDates = []

    # render top bar in modal style, without tab pills for navigation
    @topBar.render 'measure', false
    
    @render()
  template: JST["app/templates/top_bar/measure_tab_count_enter"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template

    # set the start time to now
    start = new XDate
    @countSession.set
      start: start.toString()

    # set the end time; this is used by the setInterval  
    # function to see if the CountSession is over yet
    @endTime = start.addSeconds @countSession.get('duration_seconds')

    # and this is used to update the timer display
    @millisecondsRemaining = @countSession.get('duration_seconds') * 1000

    # initialize and start the timer
    timer = setInterval =>
      now = new XDate
      if now > masterRouter.measureTab.endTime
        clearInterval timer
        masterRouter.measureTab.finish()
      else
        masterRouter.measureTab.redrawTimer()
    , 1000 # run every second
    # add it to the timers array so that it can be cleared later
    masterRouter.timers.push timer
      
    # plusOneBeep = new Audio "/media/audio/plus_one_beep.mp3"
    # plusTwoBeep = new Audio "/media/audio/plus_two_beep.mp3"
    # minusOneBeep = new Audio "/media/audio/minus_one_beep.mp3"
      
    # bindings for buttons
    $('#cancel-counting-button').on "click touchstart", $.proxy @cancelCountingButtonClick, this
    $('#count-plus-one-button').on "click touchstart", $.proxy @countPlusOneButtonClick, this
    $('#count-plus-five-button').on "click touchstart", $.proxy @countPlusFiveButtonClick, this
    $('#count-minus-one-button').on "click touchstart", $.proxy @countMinusOneButtonClick, this

  cancelCountingButtonClick: ->
    bootbox.confirm "Are you sure you want to cancel counting?", (confirm) ->
      if confirm
        # remove timers
        masterRouter.clearTimers()
        # clear array
        @countSessionDates = []
        # remove the CountSession
        masterRouter.count_sessions.remove @countSession
        # return to MeasureTabCountSchedule
        masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count", true
      
  countPlusOneButtonClick: ->
    # add the current datetime to the list
    @countSessionDates.push Date()
    @redrawCounter()
    # plusOneBeep.src = plusOneBeep.src
    # plusOneBeep.play()
    
  countPlusFiveButtonClick: ->
    for num in [1..5]
      # add the current datetime to the list, five times
      @countSessionDates.push Date() 
    @redrawCounter()
    # plusTwoBeep.src = plusTwoBeep.src
    # plusTwoBeep.play()
    
  countMinusOneButtonClick: ->
    # remove the last datetime from the list
    @countSessionDates.pop()
    @redrawCounter()
    # minusOneBeep.src = minusOneBeep.src
    # minusOneBeep.play()

  redrawCounter: ->
    $('#counter').html "#{@countSessionDates.length} <h6>people</h6>"

  redrawTimer: ->
    @millisecondsRemaining = @millisecondsRemaining - 1000
    minutes = Math.floor (@millisecondsRemaining / (60 * 1000))
    seconds = (@millisecondsRemaining % (60 * 1000)) / 1000
    $('#timer #minutes').html "#{minutes} minutes"
    $('#timer #seconds').html "#{seconds} seconds"

  finish: ->
    # remove timers
    masterRouter.clearTimers()

    # get the CountSession
    countSession = masterRouter.count_sessions.selected()[0]

    # set stop time
    stop = new XDate
    countSession.set
      stop: stop.toString()
      status: 'completed'

    # create Count objects
    _.each masterRouter.measureTab.countSessionDates, (cdt) ->
      count = new App.Models.Count
      count.set
        count_session_id: countSession.id
        at: cdt
      countSession.counts.add count

    # advance to MeasureTabCountValidate
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count/validate/count_session/#{countSession.cid}", true