class App.Routers.Master extends Backbone.Router
  initialize: (options) ->
    # event bindings
    window.masterRouter = this
    
    # @bind "all", ->
    #   console.log "CHANGED TO: " + route = arguments[0].replace(/^route:/, '')
    # 
    # window.masterRouter.bind "changeMode", (oldMode, newMode) ->
    #   console.log "changeMode: #{oldMode} --> #{newMode}"
    # window.masterRouter.bind "changeMapMode", (mapMode) ->
    #   console.log "mapMode: #{mapMode}"
    
    window.segments = new App.Collections.Segments
    window.geo_points = new App.Collections.GeoPoints
    window.geo_point_on_segments = new App.Collections.GeoPointOnSegments
    
    new App.Views.Spinner

    @fetchData()
      
    # render views
    new App.Views.SidebarAccordion
    new App.Views.BottomBar
      geo_points: geo_points
      segments: segments
    new App.Views.Map
    
    window.geo_point_layer = new App.Views.GeoPointLayer
      collection: geo_points
    window.segment_layer = new App.Views.SegmentLayer
      collection: segments

  fetchData: ->
    # order the fetching of the data, because Segment's depend on GeoPoint's
    geo_points.fetch
      success: ->
        segments.fetch()
        
  routes:
    "user"                                     : "user"
    "project"                                  : "project"
    "map/view"                                 : "mapView"
    "map/edit"                                 : "mapEdit"
    "map/edit/geo_point/move/:geo_point_id"    : "mapMoveGeoPoint"
    "map/edit/geo_point/connect/:geo_point_id" : "mapConnectGeoPoint"
    "measure"                                  : "measure"
    "modify"                                   : "modify"
    ".*"                                       : "index"

  user: ->
    # console.log 'user'
  project: ->
    # console.log 'project'
  mapView: ->
    # window.masterRouter.trigger "changeMapMode", "view"
  mapEdit: ->
    # window.masterRouter.trigger "changeMapMode", "edit"
  mapMoveGeoPoint: ->
    #
  mapConnectGeoPoint: ->
    #
  measure: ->
    # console.log 'measure'
  modify: ->
    # console.log 'modify'
  index: ->
    # console.log 'index'