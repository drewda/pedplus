class App.Views.ModelTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    @projectId = @options.projectId
    
    @projects.bind "reset", @render, this

    @topBar.render 'model', @projectId
    
    @render()
  template: JST["app/templates/top_bar/model_tab"]
  render: ->
    $('#tab-area').empty().html @template