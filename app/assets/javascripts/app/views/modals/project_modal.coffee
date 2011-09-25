class App.Views.ProjectModal extends Backbone.View
  initialize: ->
    @render()
    @options.projects.bind "reset", @update, this if @options.mode == "open"
  id: 'project-modal'
  template: JST["app/templates/modals/project_modal"]
  render: ->
    $('body').append @template @options
    $('#project-modal').modal
      backdrop: "static" # TODO: this doesn't seem to be working
      show: true
  update: ->
    $('#project-modal').html @template @options