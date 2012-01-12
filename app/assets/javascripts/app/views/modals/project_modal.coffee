class App.Views.ProjectModal extends Backbone.View
  initialize: ->
    @render()
  id: 'project-modal'
  template: JST["app/templates/modals/project_modal"]
  render: ->
    $('body').append @template @options
    $('#project-modal').modal
      backdrop: "static"
      show: true
  update: ->
    $('#project-modal').html @template @options