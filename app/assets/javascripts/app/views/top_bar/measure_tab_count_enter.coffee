class App.Views.MeasureTabCountEnter extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @countSession = masterRouter.count_sessions.get @options.countSessionId    
    
    # initialize the array that will hold timestamps for the counts
    # in the future this may be a few arrays, one for each class of count
    # like male, female, etc.
    @countSessionDates = []
  
    @millisecondsTotal = @countSession.get 'duration_seconds' * 1000
    @millisecondsRemaining = @millisecondsTotal
    @endTime = null

    # render top bar in modal style, without tab pills for navigation
    @topBar.render 'measure', false
    
    @render()
  template: JST["app/templates/top_bar/measure_tab_count_enter"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template



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