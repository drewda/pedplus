class App.Views.NewCountSessionModal extends Backbone.View
  initialize: ->
    @render()
  id: 'new-count-session-modal'
  template: JST["app/templates/modals/new_count_session_modal"]
  render: ->
    $('body').append @template @options
    $('#new-count-session-modal').modal
      backdrop: "static" # TODO: this doesn't seem to be working
      show: true
    $('#start-count-session-now-button').bind "click", (event) =>
      countSession = new App.Models.CountSession
      masterRouter.count_sessions.add countSession
      countSession.save
        user_id: masterRouter.users.getCurrentUser().id
        project_id: masterRouter.projects.getCurrentProjectId()
        segment_id: masterRouter.segments.selected()[0].id
        total_count: 0 # just because this might trigger a change on a App.Views.CountSessionRow
                       # we don't actually want to upload that value, as total_count is a method
      ,
        success: ->      
          countSession.select()
          
          $('#new-count-session-modal').modal('hide').remove()
          masterRouter.modals = []
          masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count_session/enter/#{countSession.id}", true
        error: ->
          alert 'error saving count session to server'