class Smartphone.Views.ValidateCountPage extends Backbone.View
  el: '#validate-count-page'
  initialize: ->
    # look up the appropriate CountSession
    @countSession = masterRouter.count_sessions.getByCid @options.countSessionCid

    console.log @countSession

    # display the appropriate number of pedestrians counted
    $('#number-counted').text @countSession.counts.length

    # button bindings
    $('#delete-count-session-button').on "click", $.proxy @deleteCountSessionButtonClick, this
    $('#edit-count-session-button').on "click", $.proxy @editCountSessionButtonClick, this
    $('#save-count-session-button').on "click", $.proxy @saveCountSessionButtonClick, this

  deleteCountSessionButtonClick: ->
    $('<div>').simpledialog2
      mode: 'blank'
      blankContent : 
        '<h3>Are you sure you want to delete this count session?</h3>' +
        '<a id="yes-delete-count-session-button" data-role="button">Yes</a>'+
        '<a rel="close" data-role="button">No</a>'
    $('#yes-delete-count-session-button').on "click", $.proxy, @yesDeleteCountSessionButtonClick, this
  yesDeleteCountSessionButtonClick: ->
    # remove the CountSession
    masterRouter.count_sessions.remove @countSession
    # close and destroy the dialog
    $.mobile.sdCurrentDialog.close()
    # return to ShowCountSchedule
    $.mobile.changePage "#show-count-schedule?projectId=#{masterRouter.projects.getCurrentProjectId()}"

  editCountSessionButtonClick: ->
    # TODO: add an edit button and the necessary functionality

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
            $.mobile.changePage "#show-count-schedule?projectId=#{masterRouter.projects.getCurrentProjectId()}"
      error: ->
        # TODO: redo for jqm dialogs
        bootbox.alert 'Error uploading count session to the server. It is now necessary to restart.', (ok) ->
          window.location.reload()