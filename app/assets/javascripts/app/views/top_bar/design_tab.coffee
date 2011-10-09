class App.Views.DesignTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    
    @renderData =
      projectName: masterRouter.projects.getCurrentProject().get('name')
      projectId: masterRouter.projects.getCurrentProjectId()
    
    @projects.bind "reset", @render, this

    @topBar.render 'design'
    
    @render()
  template: JST["app/templates/top_bar/design_tab"]
  render: ->
    $('#tab-area').empty().html @template @renderData