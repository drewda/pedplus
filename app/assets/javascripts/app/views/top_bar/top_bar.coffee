class App.Views.TopBar extends Backbone.View
  template: JST["app/templates/top_bar/top_bar"]
  render: (mode) ->
    $('#top-bar').empty().html @template
      projectId: masterRouter.projects.getCurrentProjectId()
    $("##{mode}-pill").addClass('active')