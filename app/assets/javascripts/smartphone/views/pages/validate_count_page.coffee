class Smartphone.Views.ValidateCountPage extends Backbone.View
  initialize: ->
    # look up the appropriate CountSession
    @countSession = masterRouter.count_sessions.getByCid @options.countSessionCid

    # display the appropriate number of pedestrians counted
    $('#number-counted').text @countSession.counts.length

    # remove any previous button bindings
    $('#delete-count-session-button').off()
    # $('#edit-count-session-button').off()
    $('#save-count-session-button').off()

    # button bindings
    $('#delete-count-session-button').on "vclick", $.proxy @deleteCountSessionButtonClick, this
    # $('#edit-count-session-button').on "vclick", $.proxy @editCountSessionButtonClick, this
    $('#save-count-session-button').on "vclick", $.proxy @saveCountSessionButtonClick, this

  deleteCountSessionButtonClick: ->
    $('#delete-count-session-button .ui-btn-text').text('Press Again to Delete')
    $('#delete-count-session-button .ui-btn-text').off()
    $('#delete-count-session-button .ui-btn-text').on "vclick", masterRouter.validateCountPage.yesDeleteCountSessionButtonClick
  yesDeleteCountSessionButtonClick: ->
    # reset the button text
    $('#delete-count-session-button .ui-btn-text').text('Delete') # TODO: check this!
    # remove the CountSession
    masterRouter.count_sessions.remove @countSession
    # return to ShowCountSchedule
    $.mobile.changePage "#show-count-schedule?projectId=#{masterRouter.projects.getCurrentProjectId()}"

  editCountSessionButtonClick: ->
    # TODO: add an edit button and the necessary functionality

  saveCountSessionButtonClick: ->
    $.mobile.showPageLoadingMsg()
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
            $.mobile.hidePageLoadingMsg()
            # return to ShowCountSchedule
            $.mobile.changePage "#show-count-schedule?projectId=#{masterRouter.projects.getCurrentProjectId()}"
      error: ->
        $.mobile.hidePageLoadingMsg()
        # TODO: redo for jqm dialogs
        bootbox.alert 'Error uploading count session to the server. It is now necessary to restart.', (ok) ->
          window.location.reload()