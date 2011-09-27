class App.Views.MapTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    
    @projects.bind 'reset', @render, this

    @renderData =
      projectId: @options.projectId
      geoPointId: @options.geoPointId
      segmentId: @options.segmentId
      mapMode: @options.mapMode
      mapEditsLength: @options.map_edits.length

    @topBar.render 'map'
    
    @render()
  template: JST["app/templates/top_bar/map_tab"]
  render: ->    
    $('#tab-area').empty().html @template @renderData