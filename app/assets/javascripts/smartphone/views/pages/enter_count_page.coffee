class Smartphone.Views.EnterCountPage extends Backbone.View
  el: '#enter-count-page'
  initialize: ->
    # look up the appropriate CountSession
    @countSession = masterRouter.count_sessions.getByCid @options.countSessionCid

    # initialize the array that will hold timestamps for the counts
    # in the future this may be a few arrays, one for each class of count
    # like male, female, etc.
    @countSessionDates = []

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
      if now > masterRouter.enterCountPage.endTime
        clearInterval timer
        masterRouter.enterCountPage.finish()
      else
        masterRouter.enterCountPage.redrawTimer()
    , 1000 # run every second
    # add it to the timers array so that it can be cleared later
    masterRouter.timers.push timer

    # display the proper header title
    $('.header-gate-label-span').text @countSession.getGate().printLabel()

    # button bindings
    $('#count-plus-five-button').on "click touchstart", $.proxy @countPlusFiveButtonClick, this
    $('#count-plus-one-button').on "click touchstart", $.proxy @countPlusOneButtonClick, this
    $('#count-minus-one-button').on "click touchstart", $.proxy @countMinusOneButtonClick, this
    $('#cancel-counting-button').on "click touchstart", $.proxy @cancelCountingButtonClick, this

  cancelCountingButtonClick: ->
    # TODO: write the appropriate dialog code for jqm
    bootbox.confirm "Are you sure you want to cancel counting?", (confirm) ->
      if confirm
        # remove timers
        masterRouter.clearTimers()
        # clear array
        @countSessionDates = []
        # remove the CountSession
        masterRouter.count_sessions.remove @countSession
        # return to ShowCountSchedule
        window.history.back(-1)

  countPlusOneButtonClick: ->
    # add the current datetime to the list
    @countSessionDates.push Date()
    @redrawCounter()
    
  countPlusFiveButtonClick: ->
    for num in [1..5]
      # add the current datetime to the list, five times
      @countSessionDates.push Date() 
    @redrawCounter()
    
  countMinusOneButtonClick: ->
    # remove the last datetime from the list
    @countSessionDates.pop()
    @redrawCounter()

  redrawCounter: ->
    $('#counter-number').text @countSessionDates.length

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
    window.location = "/smartphone#verify-count?projectId=#{projectId}&countSessionCid=#{countSession.cid}"