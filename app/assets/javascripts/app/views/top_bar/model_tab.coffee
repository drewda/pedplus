class App.Views.ModelTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    
    @projects.bind "reset", @render, this

    @topBar.render 'model'
    
    @render()
  template: JST["app/templates/top_bar/model_tab"]
  render: ->
    $('#tab-area').empty().html @template