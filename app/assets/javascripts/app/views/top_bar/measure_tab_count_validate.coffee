class App.Views.MeasureTabCountValidate extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @countSession = masterRouter.count_sessions.getByCid @options.countSessionCid

    # render top bar in modal style, without tab pills for navigation
    @topBar.render 'measure', false
    
    @render()
  template: JST["app/templates/top_bar/measure_tab_count_validate"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template
      counts_count: @countSession.counts.length

    # bindings for buttons
    $('#delete-button').on "click", $.proxy @deleteButtonClick, this
    $('#edit-button').on "click", $.proxy @editButtonClick, this
    $('#save-button').on "click", $.proxy @saveButtonClick, this

  deleteButtonClick: ->
    bootbox.confirm "Are you sure you want to delete this count session?", (confirm) ->
      if confirm
        # remove the CountSession
        masterRouter.count_sessions.remove @countSession
        # return to MeasureTabCountSchedule
        masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count", true

  editButtonClick: ->
    # remove the edit button
    $('#edit-button').remove()
    # replace the question text with the shorter text
    $('h2').text "#{@countSession.counts.length} pedestrians"
    # show the edit count buttons
    $('#count-edit-buttons').show()

    # bindings for the edit count buttons
    $('#minus-one-button').on "click", $.proxy ->
      # remove the last Count
      @countSession.counts.pop()
      # update the text
      $('h2').text "#{@countSession.counts.length} pedestrians"
    , this
    $('#plus-one-button').on "click", $.proxy ->
      # add another Count, with the CountSession's end time
      count = new App.Models.Count
        at: @countSession.get('stop')
      @countSession.counts.add count
      # update the text
      $('h2').text "#{@countSession.counts.length} pedestrians"
    , this

  saveButtonClick: ->
    # upload the CountSession with its Count's to the server
    @countSession.save
      counts: @countSession.counts.toJSON()
    ,
      success: ->
        # unselect the CountSession
        masterRouter.count_sessions.selected()[0].deselect()
        # reset and reload the CountSessions data
        masterRouter.count_sessions.reset()
        masterRouter.count_sessions.fetch
          success: ->
            # return to MeasureTabCountSchedule
            masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count", true
      error: ->
        # TODO: provide a way to recover and do a local save of the CountSession and its Count's
        bootbox.alert 'Error uploading count session to the server. It is now necessary to restart.', (ok) ->
          window.location.reload()