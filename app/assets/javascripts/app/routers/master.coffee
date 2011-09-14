class App.Routers.Master extends Backbone.Router
  initialize: (options) ->
    # fetch data
    @segments = new App.Collections.Segments
    @geo_points = new App.Collections.GeoPoints
    
    @segments.fetch()
    @geo_points.fetch()
    
    # DEBUG
    # window.segments = @segments
    # window.geo_points = @geo_points
    
    # render views
    new App.Views.SidebarAccordion
    new App.Views.BottomBar
      geo_points: @geo_points
    new App.Views.Map
    
    window.geo_point_layer = new App.Views.GeoPointLayer
      collection: @geo_points
    window.segment_layer = new App.Views.SegmentLayer
      collection: @segments

  routes:
    "user"    : "user"
    "project" : "project"
    "map"     : "map"
    "measure" : "measure"
    "modify"  : "modify"
    ".*"      : "index"

  user: ->
    console.log 'user'
  project: ->
    console.log 'project'
  map: ->
    console.log 'map'
  measure: ->
    console.log 'measure'
  modify: ->
    console.log 'modify'
  index: ->
    console.log 'index'