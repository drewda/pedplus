class App.Views.ProjectTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    
    @projects.bind "reset", @render, this

    @topBar.render 'project'
    
    @render()
  template: JST["app/templates/top_bar/project_tab"]
  render: ->
    $('#tab-area').html @template @projects.getCurrentProject()
  remove: ->
    @projects.unbind()
    $('#project-tab').remove()