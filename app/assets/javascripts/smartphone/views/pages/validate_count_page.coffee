class Smartphone.Views.ValidateCountPage extends Backbone.View
  el: '#validate-count-page'
  initialize: ->
    # look up the appropriate CountSession
    @countSession = masterRouter.count_sessions.getByCid @options.countSessionCid

    # TODO: do something about the dialog close button

    # button bindings
    $('#delete-count-session-button').on "click touchstart", $.proxy @deleteCountSessionButtonClick, this
    $('#edit-count-session-button').on "click touchstart", $.proxy @editCountSessionButtonClick, this
    $('#save-count-session-button').on "click touchstart", $.proxy @saveCountSessionButtonClick, this

  deleteCountSessionButtonClick: ->
    # TODO: redo for jqm dialogs
    bootbox.confirm "Are you sure you want to delete this count session?", (confirm) ->
      if confirm
        # remove the CountSession
        masterRouter.count_sessions.remove @countSession
        # return to MeasureTabCountSchedule
        masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count", true

  editCountSessionButtonClick: ->
    # TODO

  saveCountSessionButtonClick: ->
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
            # return to ShowCountSchedule
            window.location = "/smartphone#show-count-schedule?projectId=#{masterRouter.projects.getCurrentProjectId()}"
      error: ->
        # TODO: redo for jqm dialogs
        bootbox.alert 'Error uploading count session to the server. It is now necessary to restart.', (ok) ->
          window.location.reload()