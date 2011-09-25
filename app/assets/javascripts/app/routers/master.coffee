class App.Routers.Master extends Backbone.Router
  initialize: (options) ->
    # this is how masterRouter will be referred to from other objects
    window.masterRouter = this
    
    # initialize collections, but don't yet fetch()
    @projects = new App.Collections.Projects
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
    
    @projects.fetch()
    
    window.geo_point_layer = new App.Views.GeoPointLayer
       geo_points: @geo_points
    window.segment_layer = new App.Views.SegmentLayer
      collection: @segments
        
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
    "project/:project_id/map/geo_point/:geo_point_id/delete"   : "mapDeleteGeoPoint"
    "project/:project_id/map/segment/:segment_id"              : "mapSelectedSegment"
    "project/:project_id/map/segment/:segment_id/delete"       : "mapDeleteSegment"
    "project/:project_id/map/upload_edits"                     : "mapUploadEdits"

    "project/:project_id/model" : "model"

    "project/:project_id/measure" : "measure"

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
    console.log 'map'
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
    
  mapSelectedGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
    
  mapMoveGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      geoPointId: geoPointId
    
  mapConnectGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      geoPointId: geoPointId
    
  mapDeleteGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      geoPointId: geoPointId
    
  mapSelectedSegment: (projectId, segmentId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      segmentId: segmentId
    
  mapDeleteSegment: (projectId, segmentId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      segmentId: segmentId
      
  mapUploadEdits: (projectId) ->
    @reset(projectId)
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects      
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
    @reset(projectId)
    new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects

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
    
  reset: (projectId) ->
    if projectId
      masterRouter.projects.setCurrentProjectId projectId
    else
      masterRouter.projects.setCurrentProjectId 0
    $('.modal').modal('hide').remove()
    $('.modal-backdrop').remove()
    masterRouter.topBarTabs = []
    masterRouter.modals = []
    