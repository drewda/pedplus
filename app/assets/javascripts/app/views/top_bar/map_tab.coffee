class App.Views.MapTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    @projectId = @options.projectId
    
    @projects.bind 'reset', @render, this

    @topBar.render 'map', @projectId
    
    masterRouter.bind 'mapEdited', @displayUploadMapEditsButton, this
    
    @render()
  template: JST["app/templates/top_bar/map_tab"]
  render: ->
    $('#tab-area').empty().html @template
  displayUploadMapEditsButton: ->
    $('#upload-map-edits-button').show().bind "click", (event) =>
      masterRouter.navigate "project/#{@projectId}/map/upload_edits", true
    