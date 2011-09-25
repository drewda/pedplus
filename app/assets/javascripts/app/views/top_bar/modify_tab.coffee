class App.Views.ModifyTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    @projectId = @options.projectId
    
    @projects.bind "reset", @render, this

    @topBar.render 'modify', @projectId
    
    @render()
  template: JST["app/templates/top_bar/modify_tab"]
  render: ->
    $('#tab-area').empty().html @template