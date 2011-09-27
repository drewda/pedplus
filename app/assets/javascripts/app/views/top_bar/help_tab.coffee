class App.Views.HelpTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    
    @projects.bind "reset", @render, this

    @topBar.render 'help'
    
    @render()
  template: JST["app/templates/top_bar/help_tab"]
  render: ->
    $('#tab-area').empty().html @template