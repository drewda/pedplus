class App.Views.BottomBar extends Backbone.View
  id: 'bottom-bar'
  initialize: ->
    @geo_points = @options.geo_points
    @segments = @options.segments
    
    @render()
    
    @geo_points.bind  'selection',  @selectionChange, this
    @segments.bind    'selection',  @selectionChange, this
  render: ->
    # $('#bottom-bar').hide()
  selectionChange: ->
    if @geo_points.selected().length == 1
      # $('#bottom-bar').slideDown()
      new App.Views.GeoPointBottomBar
    else if @segments.selected().length == 1
      # $('#bottom-bar').slideDown()
      new App.Views.SegmentBottomBar
    else
      # $('#bottom-bar').slideUp()