class App.Views.BottomBar extends Backbone.View
  initialize: ->
    @geo_points = @options.geo_points
    
    @render()
    @geo_points.bind 'selection', @geoPointChange, this
  render: ->
    $('#bottom-bar').hide()
  geoPointChange: ->
    if @geo_points.selected().length > 0
      $('#bottom-bar').slideDown()
    else if @geo_points.selected().length == 0
      $('#bottom-bar').slideUp()