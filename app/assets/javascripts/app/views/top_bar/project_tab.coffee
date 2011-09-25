class App.Views.ProjectTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    @projectId = @options.projectId
    
    @projects.bind "reset", @render, this

    @topBar.render 'project', @projectId
    
    @render()
  template: JST["app/templates/top_bar/project_tab"]
  render: ->
    $('#tab-area').html @template @projects.get(@projectId).toJSON()