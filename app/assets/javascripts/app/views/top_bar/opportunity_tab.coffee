class App.Views.OpportunityTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    
    @renderData = 
      projectId: @projects.getCurrentProjectId()
    
    @projects.bind "reset", @render, this

    @topBar.render 'opportunity'
    
    @render()
  template: JST["app/templates/top_bar/opportunity_tab"]
  render: ->
    $('#tab-area').empty().html @template @renderData