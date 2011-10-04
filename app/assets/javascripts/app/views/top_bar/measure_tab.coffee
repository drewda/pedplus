class App.Views.MeasureTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    @mode = @options.mode
    
    @renderData =
      projectId: @options.projectId
      segmentId: @options.segmentId
      mode: @options.mode
    
    @projects.bind "reset", @render, this

    @topBar.render 'measure'
    
    if @mode == "enterCountSession"
      @countSession = masterRouter.count_sessions.get @options.countSessionId
      @countSession.counts.bind "add", @redrawCounter, this
      @countSession.counts.bind "remove", @redrawCounter, this
    
    @minutes = 5
    @millisecondsTotal = @minutes * 60 * 1000
    @millisecondsRemaining = @millisecondsTotal
    @endTime = null
    
    @render()
  template: JST["app/templates/top_bar/measure_tab"]
  render: ->
    $('#tab-area').empty().html @template @renderData
      
    if @options.mode == "enterCountSession"
      # don't show the pills to navigate to other modes
      $('#top-bar .pills').remove()
      
      @countSession.set
        start: new Date
      
      # set the end time
      @endTime = new Date();
      @endTime.setMinutes(@endTime.getMinutes() + @minutes)
      
      # setTimeout =>
      #   masterRouter.measureTab.finish()
      # , @millisecondsTotal
      timer = setInterval =>
        now = new Date
        if now > @endTime
          clearInterval timer
          masterRouter.measureTab.finish()
        masterRouter.measureTab.redrawTimer()
      , 1000 # run every minute
      
      # plusOneBeep = new Audio "/media/audio/plus_one_beep.mp3"
      # plusTwoBeep = new Audio "/media/audio/plus_two_beep.mp3"
      # minusOneBeep = new Audio "/media/audio/minus_one_beep.mp3"
      
      $('#stop-count-session-early-button').bind "click", (event) =>
        masterRouter.measureTab.finish()
        
      $('#count-plus-one-button').bind "click", (event) =>
        @countSession = masterRouter.count_sessions.selected()[0]
        count = new App.Models.Count
        count.set
          count_session_id: @countSession.id
          at: new Date
        @countSession.counts.add count
        # plusOneBeep.src = plusOneBeep.src
        # plusOneBeep.play()
      
      $('#count-plus-five-button').bind "click", (event) =>
        @countSession = masterRouter.count_sessions.selected()[0]
        for num in [1..5]
          count = new App.Models.Count
          count.set
            count_session_id: @countSession.id
            at: new Date
          @countSession.counts.add count
        # plusTwoBeep.src = plusTwoBeep.src
        # plusTwoBeep.play()
      
      $('#count-minus-one-button').bind "click", (event) =>
        @countSession.counts.remove @countSession.counts.last()
        # minusOneBeep.src = minusOneBeep.src
        # minusOneBeep.play()
  redrawCounter: ->
    $('#counter').html "#{@countSession.counts.length} <h6>people</h6>"
  redrawTimer: ->
    @millisecondsRemaining = @millisecondsRemaining - 1000
    minutes = Math.floor (@millisecondsRemaining / (60 * 1000))
    seconds = (@millisecondsRemaining % (60 * 1000)) / 1000
    $('#timer #minutes').html "#{minutes} minutes"
    $('#timer #seconds').html "#{seconds} seconds"
  finish: ->
    masterRouter.clearTimers()
    countSession = masterRouter.count_sessions.selected()[0]
    countSession.set
      stop: new Date
    countSession.uploadCounts
      success: ->
        masterRouter.count_sessions.fetch()
        masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count_session/#{masterRouter.count_sessions.selected()[0].id}", true