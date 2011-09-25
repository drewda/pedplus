class App.Views.TopBar extends Backbone.View
  template: JST["app/templates/top_bar/top_bar"]
  render: (mode, projectId) ->
    $('#top-bar').empty().html @template
      projectId: projectId
    $("##{mode}-pill").addClass('active')