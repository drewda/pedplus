class App.Views.MeasureTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    @projectId = @options.projectId
    
    @projects.bind "reset", @render, this

    @topBar.render 'measure', @projectId
    
    @render()
  template: JST["app/templates/top_bar/measure_tab"]
  render: ->
    $('#tab-area').empty().html @template