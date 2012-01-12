class App.Views.ProjectsModal extends Backbone.View
  initialize: ->
    @render()
    @options.projects.bind "reset", @update, this if @options.mode == "open"
  id: 'projects-modal'
  template: JST["app/templates/modals/projects_modal"]
  render: ->
    $('body').append @template @options
    $('#projects-modal').modal
      backdrop: "static"
      show: true
  update: ->
    $('#projects-modal').html @template @options