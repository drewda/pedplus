class App.Routers.Master extends Backbone.Router
  initialize: (options) ->
    # this is how masterRouter will be referred to from other objects
    window.masterRouter = this
    
    # initialize collections, but don't yet fetch()
    @projects = new App.Collections.Projects
    injectProjects() # projects will be injected by dashboard.slim
    @segments = new App.Collections.Segments
    @geo_points = new App.Collections.GeoPoints
    @geo_point_on_segments = new App.Collections.GeoPointOnSegments
    @map_edits = new App.Collections.MapEdits
    
    # new App.Views.Spinner
      
    # render views
    new App.Views.Map
      projects: @projects
    new App.Views.ActivityBox
    @topBar = new App.Views.TopBar
    @topBarTabs = []
    @modals = []
    
    @geo_point_layer = new App.Views.GeoPointLayer
       geo_points: @geo_points
       geoPointDefaultRadius: 8
       geoPointSelectedRadius: 12
       geoPointConnectedRadius: 12
    @segment_layer = new App.Views.SegmentLayer
      collection: @segments
      segmentDefaultStrokeWidth: 5
      segmentSelectedStrokeWidth: 8
    
    @currentRouteName = ""
    @bind "all", @routeNameKeeper
     
  routeNameKeeper: (route) ->
    @currentRouteName = route.split(':').pop()
    # if the current URL ends with an ID of the form c#
    # then we'll attach that after the route name
    if location.hash.split('/').pop().match(/c\d+/)
      @currentRouteName += ":" + location.hash.split('/').pop()
        
  routes:
    ".*" : "index"
    
    "user/setings" : "userSettings"
    
    "message/new" : "messageNew"
    
    "project/open"                  : "projectOpen"
    "project/new"                   : "projectNew"
    "project/:project_id"           : "project"
    "project/:project_id/settings"  : "projectSettings"
    
    "project/:project_id/map"                                  : "map"
    "project/:project_id/map/geo_point/:geo_point_id"          : "mapSelectedGeoPoint"
    "project/:project_id/map/geo_point/move/:geo_point_id"     : "mapMoveGeoPoint"
    "project/:project_id/map/geo_point/connect/:geo_point_id"  : "mapConnectGeoPoint"
    "project/:project_id/map/geo_point/delete/:geo_point_id"   : "mapDeleteGeoPoint"
    "project/:project_id/map/segment/:segment_id"              : "mapSelectedSegment"
    "project/:project_id/map/segment/delete/:segment_id"       : "mapDeleteSegment"
    "project/:project_id/map/upload_edits"                     : "mapUploadEdits"

    "project/:project_id/model" : "model"

    "project/:project_id/measure"                                         : "measure"
    "project/:project_id/measure/segment/:segment_id"                     : "measureSelectedSegment"
    "project/:project_id/measure/segment/:segment_id/count_session/new"   : "measureNewCountSessionAtSelectedSegment"
    "project/:project_id/measure/count_session/:count_session_id"         : "measureSelectedCountSession"
    "project/:project_id/measure/count_session/enter/:count_session_id"   : "measureEnterCountSession"
    "project/:project_id/measure/count_session/delete/:count_session_id"  : "measureDeleteCountSession"

    "project/:project_id/modify" : "modify"
    
    "project/:project_id/help" : "help"

  index: ->
    masterRouter.navigate 'project/open', true

  userSettings: ->
    @reset()

  messageNew: ->
    @reset()

  projectOpen: ->
    @reset()
    projectModal = new App.Views.ProjectModal
      mode: "open"
      projects: masterRouter.projects
    masterRouter.modals.push projectModal

  projectNew: ->
    @reset()
    projectModal = new App.Views.ProjectModal
      mode: "new"
      projects: masterRouter.projects
    masterRouter.modals.push projectModal

  project: (projectId) ->
    @reset(projectId)
    # topBar
    projectTab = new App.Views.ProjectTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
    masterRouter.topBarTabs.push projectTab
    # fetch project data
    masterRouter.geo_points.fetch
      success: ->
        masterRouter.geo_point_on_segments.fetch
          success: -> 
            masterRouter.segments.fetch()
  
  projectSettings: (projectId) ->
    reset(projectId)  
    new App.Views.ProjectTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
  
  map: (projectId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      map_edits: masterRouter.map_edits
    
  mapSelectedGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      geoPointId: geoPointId
      mapMode: 'geoPointSelected'
      map_edits: masterRouter.map_edits
    
  mapMoveGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      geoPointId: geoPointId
      mapMode: 'geoPointMove'
      map_edits: masterRouter.map_edits
    
  mapConnectGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      geoPointId: geoPointId
      mapMode: 'geoPointConnect'
      map_edits: masterRouter.map_edits
    
  mapDeleteGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      geoPointId: geoPointId
      mapMode: 'geoPointDelete'
      map_edits: masterRouter.map_edits
    deleteGeoPointModal = new App.Views.DeleteGeoPointModal
        geoPointId: geoPointId
    masterRouter.modals.push deleteGeoPointModal
    
  mapSelectedSegment: (projectId, segmentId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      segmentId: segmentId
      mapMode: 'segmentSelected'
      map_edits: masterRouter.map_edits
    
  mapDeleteSegment: (projectId, segmentId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      segmentId: segmentId
      mapMode: 'segmentDelete'
      map_edits: masterRouter.map_edits
    deleteSegmentModal = new App.Views.DeleteSegmentModal
        segmentId: segmentId
    masterRouter.modals.push deleteSegmentModal
      
  mapUploadEdits: (projectId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects      
      map_edits: masterRouter.map_edits
    uploadMapEditsModal = new App.Views.UploadMapEditsModal
      projectId: projectId
      projects: masterRouter.projects
    masterRouter.modals.push uploadMapEditsModal

  model: (projectId) ->
    @reset(projectId)
    new App.Views.ModelTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects

  measure: (projectId) ->
    @reset(projectId, 240)
    new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
  
  measureSelectedSegment: (projectId, segmentId) ->
    @reset(projectId, 240)
    new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      segmentId: segmentId
      
  measureNewCountSessionAtSelectedSegment: (projectId, segmentId) ->
    @reset(projectId, 240)
    new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      segmentId: segmentId
    newCountSessionModal = new App.Views.NewCountSessionModal
      segmentId: segmentId
    masterRouter.modals.push newCountSessionModal
      
  measureSelectedCountSession: (projectId, countSessionId) ->
    @reset(projectId, 240)
    new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      countSessionId: countSessionId

  measureEnterCountSession: (projectId, countSessionId) ->
    @reset(projectId, 240)
    new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      countSessionId: countSessionId

  measureDeleteCountSession: (projectId, countSessionId) ->
    @reset(projectId, 240)
    new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      countSessionId: countSessionId
    deleteCountSessionModal = new App.Views.DeleteCountSessionModal
        countSessionId: countSessionId
    masterRouter.modals.push deleteCountSessionModal

  modify: (projectId) ->
    @reset(projectId)
    new App.Views.ModifyTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
    
  help: (projectId) ->
    @reset(projectId)
    new App.Views.HelpTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
    
  reset: (projectId, topBarHeight = 90) ->
    if projectId
      masterRouter.projects.setCurrentProjectId projectId
    else
      masterRouter.projects.setCurrentProjectId 0
    $('.modal').modal('hide').remove()
    $('.modal-backdrop').remove()
    masterRouter.topBarTabs = []
    masterRouter.modals = []
    $('#top-bar').animate {height:"#{topBarHeight}px"}, 400 unless $('#top-bar').height == topBarHeight 
    