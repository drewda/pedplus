class App.Routers.Master extends Backbone.Router
  initialize: (options) ->
    # this is how masterRouter will be referred to from other objects
    window.masterRouter = this
    
    # juggernaut connect to be used for push notifications
    # as when models are complete
    # @juggernautConnector = new JuggernautConnector
    
    # initialize collections
    @projects = new App.Collections.Projects
    # injectProjects() # projects will be injected by dashboard.slim
    
    @users = new App.Collections.Users
    @users.fetch
      success: ->
        # masterRouter.juggernautConnector.subscribeToOrganization masterRouter.users.getCurrentUser().get('organization_id')
    
    # will be fetch'ed when the user selects a project
    @segments = new App.Collections.Segments
    @geo_points = new App.Collections.GeoPoints
    @geo_point_on_segments = new App.Collections.GeoPointOnSegments
    @count_sessions = new App.Collections.CountSessions
    
    # will be populated by the client-side
    @map_edits = new App.Collections.MapEdits
    
    @model_jobs = new App.Collections.ModelJobs
    
    new App.Views.Spinner
      
    # render views
    @map = new App.Views.Map
      projects: @projects
    new App.Views.ActivityBox
    @topBar = new App.Views.TopBar
    @topBarTabs = []
    @modals = []
    @projectTab = null
    @mapTab = null
    @modelTab = null
    @measureTab = null
    @opportunityTab = null
    @designTab = null
    @countSessionsTable = null
    
    @geo_point_layer = new App.Views.GeoPointLayer
      geo_points: @geo_points
      geoPointDefaultRadius: 8
      geoPointSelectedRadius: 12
      geoPointConnectedRadius: 12
    @segment_layer = new App.Views.SegmentLayer
      segments: @segments
      segmentDefaultStrokeWidth: 10
      segmentSelectedStrokeWidth: 10
    @new_segment_layer = new App.Views.NewSegmentLayer
      segments: @segments
      segmentDefaultStrokeWidth: 10
      segmentSelectedStrokeWidth: 10
    
    @currentRouteName = ""
    
    @timers = []

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

    "project/:project_id/model"                         : "model"
    "project/:project_id/model/permeability/:model_job" : "modelPermeability"

    "project/:project_id/measure"                                         : "measure"
    "project/:project_id/measure/predictions"                             : "measurePredictions"    
    "project/:project_id/measure/segment/:segment_id"                     : "measureSelectedSegment"
    "project/:project_id/measure/segment/:segment_id/count_session/new"   : "measureNewCountSession"
    "project/:project_id/measure/count_session/:count_session_id"         : "measureSelectedCountSession"
    "project/:project_id/measure/count_session/enter/:count_session_id"   : "measureEnterCountSession"
    "project/:project_id/measure/count_session/delete/:count_session_id"  : "measureDeleteCountSession"
    
    "project/:project_id/opportunity"             : "opportunity"
    # "project/:project_id/opportunity/:segment_id" : "opportunitySelectedSegment"

    "project/:project_id/design"                              : "design"
    # "project/:project_id/design/scenario/new"                 : "designScenarioNew"
    # "project/:project_id/design/scenario/edit/:scenario_id}"  : "designScenarioEdit"
    "project/:project_id/design/scenario/:scenario_id}"       : "designScenarioView"
    
    "project/:project_id/help" : "help"

  index: ->
    masterRouter.navigate 'project/open', true

  userSettings: ->
    @reset()
    @routeNameKeeper 'userSettings'

  messageNew: ->
    @reset()
    @routeNameKeeper 'messageNew'

  projectOpen: ->
    if @projectTab
      @projectTab.remove()
    masterRouter.projects.reset()
    masterRouter.projects.fetch()
    masterRouter.geo_points.reset()
    masterRouter.geo_point_on_segments.reset()
    masterRouter.segments.reset()
    @reset()
    @routeNameKeeper 'projectOpen'
    projectModal = new App.Views.ProjectModal
      mode: "open"
      projects: masterRouter.projects
    masterRouter.modals.push projectModal
    @map.setOsmLayer "color"
    @map.resetMap false, false
    @map.centerMap()

  projectNew: ->
    @reset()
    @routeNameKeeper 'projectNew'
    projectModal = new App.Views.ProjectModal
      mode: "new"
      projects: masterRouter.projects
    masterRouter.modals.push projectModal

  project: (projectId) ->
    @reset(projectId)
    @routeNameKeeper 'project'
    @fetchProjectData()
    # topBar
    @projectTab = new App.Views.ProjectTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
    masterRouter.topBarTabs.push @projectTab
    @geo_points.selectNone()
    @segments.selectNone()
    @map.setOsmLayer "color"
    @map.resetMap false, true
    @map.centerMap()
  
  projectSettings: (projectId) ->
    @reset(projectId)  
    @routeNameKeeper 'projectSettings'
    # @fetchProjectData()
    @projectTab = new App.Views.ProjectTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
  
  map: (projectId) ->
    @reset(projectId)
    @routeNameKeeper 'map'
    # @fetchProjectData()
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      map_edits: masterRouter.map_edits
    @geo_points.selectNone()
    @segments.selectNone()
    @map.setOsmLayer "color"
    @map.resetMap true, true
    @map.mapMode()
    
  mapSelectedGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    @routeNameKeeper 'mapSelectedGeoPoint'
    # @fetchProjectData()
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      geoPointId: geoPointId
      mapMode: 'geoPointSelected'
      map_edits: masterRouter.map_edits
    @map.setOsmLayer "color"
    @map.resetMap true, true
    @map.mapMode()
    
  mapMoveGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    @routeNameKeeper 'mapMoveGeoPoint'
    # @fetchProjectData()
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      geoPointId: geoPointId
      mapMode: 'geoPointMove'
      map_edits: masterRouter.map_edits
    @map.setOsmLayer "color"
    @map.resetMap true, true
    @map.moveGeoPointMode()
    
  mapConnectGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    @routeNameKeeper 'mapConnectGeoPoint'
    # @fetchProjectData()
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      geoPointId: geoPointId
      mapMode: 'geoPointConnect'
      map_edits: masterRouter.map_edits
    @map.setOsmLayer "color"
    @map.resetMap true, true
    @map.connectGeoPointMode()
    
  mapDeleteGeoPoint: (projectId, geoPointId) ->
    @reset(projectId)
    @routeNameKeeper 'mapDeleteGeoPoint'
    # @fetchProjectData()
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
    @map.setOsmLayer "color"
    @map.resetMap true, true
    
  mapSelectedSegment: (projectId, segmentId) ->
    @reset(projectId)
    @routeNameKeeper 'mapSelectedSegment'
    # @fetchProjectData()
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      segmentId: segmentId
      mapMode: 'segmentSelected'
      map_edits: masterRouter.map_edits
    @map.setOsmLayer "color"
    @map.resetMap true, true
    
  mapDeleteSegment: (projectId, segmentId) ->
    @reset(projectId)
    @routeNameKeeper 'mapDeleteSegment'
    # @fetchProjectData()
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
    @map.setOsmLayer "color"
    @map.resetMap true, true
      
  mapUploadEdits: (projectId) ->
    @reset(projectId)
    @routeNameKeeper 'mapUploadEdits'
    # @fetchProjectData()
    new App.Views.MapTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects      
      map_edits: masterRouter.map_edits
    uploadMapEditsModal = new App.Views.UploadMapEditsModal
      projectId: projectId
      projects: masterRouter.projects
    masterRouter.modals.push uploadMapEditsModal
    @map.setOsmLayer "color"
    @map.resetMap true, true

  model: (projectId) ->
    @reset(projectId)
    @routeNameKeeper 'model'
    # @fetchProjectData()
    @modelTab = new App.Views.ModelTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      mode: "model"
    @map.setOsmLayer "gray"
    @map.resetMap false, true
    masterRouter.segments.selectNone()
    
  modelPermeability: (projectId, modelJobId) ->
    @reset(projectId)
    @routeNameKeeper 'modelPermeability'
    # @fetchProjectData()
    @modelTab = new App.Views.ModelTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      modelJobId: modelJobId
      mode: "modelPermeability"
    @map.setOsmLayer "gray"
    @map.resetMap false, true
    masterRouter.segments.selectNone()

  measure: (projectId) ->
    @reset(projectId, 200)
    @routeNameKeeper 'measure'
    # @fetchProjectData()
    @measureTab = new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      mode: "measure"
    @map.setOsmLayer "gray"
    @map.resetMap false, true  
    @geo_points.selectNone()
    @segments.selectNone()
    if !@countSessionTable
      @countSessionTable = new App.Views.CountSessionTable
        count_sessions: masterRouter.count_sessions
    else
      @countSessionTable.render()
  
  measurePredictions: (projectId) ->
    @reset(projectId, 590)
    @routeNameKeeper 'measurePredictions'
    # @fetchProjectData()
    @measureTab = new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      mode: "predictions"
    @map.setOsmLayer "gray"
    @map.resetMap false, true  
    @geo_points.selectNone()
    @segments.selectNone()
  
  measureSelectedSegment: (projectId, segmentId) ->
    @reset(projectId, 200)
    @routeNameKeeper 'measureSelectedSegment'
    # @fetchProjectData()
    @measureTab = new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      segmentId: segmentId
      mode: "selectedSegment"
    if !@countSessionTable
      @countSessionTable = new App.Views.CountSessionTable
        count_sessions: masterRouter.count_sessions
    else
      @countSessionTable.render()
      
  measureNewCountSession: (projectId, segmentId) ->
    @reset(projectId, 200)
    @routeNameKeeper 'measureNewCountSession'
    # @fetchProjectData()
    @measureTab = new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      segmentId: segmentId
    newCountSessionModal = new App.Views.NewCountSessionModal
      projectId: projectId
      segmentId: segmentId
    masterRouter.modals.push newCountSessionModal
    if !@countSessionTable
      @countSessionTable = new App.Views.CountSessionTable
        count_sessions: masterRouter.count_sessions
    else
      @countSessionTable.render()
      
  measureSelectedCountSession: (projectId, countSessionId) ->
    @reset(projectId, 200)
    @routeNameKeeper 'measureSelectedCountSession'
    # @fetchProjectData()
    @measureTab = new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      countSessionId: countSessionId
      mode: "selectedCountSession"
    if !@countSessionTable
      @countSessionTable = new App.Views.CountSessionTable
        count_sessions: masterRouter.count_sessions
    else
      @countSessionTable.render()

  measureEnterCountSession: (projectId, countSessionId) ->
    @reset(projectId, 160)
    @routeNameKeeper 'measureEnterCountSession'
    # @fetchProjectData()
    if @countSessionTable
      @countSessionTable.remove()
    @measureTab = new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      countSessionId: countSessionId
      mode: "enterCountSession"

  measureDeleteCountSession: (projectId, countSessionId) ->
    @reset(projectId, 200)
    @routeNameKeeper 'measureDeleteCountSession'
    # @fetchProjectData()
    @measureTab = new App.Views.MeasureTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
      countSessionId: countSessionId
    deleteCountSessionModal = new App.Views.DeleteCountSessionModal
        countSessionId: countSessionId
    masterRouter.modals.push deleteCountSessionModal
    if !@countSessionTable
      @countSessionTable = new App.Views.CountSessionTable
        count_sessions: masterRouter.count_sessions
    else
      @countSessionTable.render()

  opportunity: (projectId) ->
    @reset(projectId, 590)
    @routeNameKeeper 'opportunity'
    # @fetchProjectData
    @opportunityTab = new App.Views.OpportunityTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
    @map.setOsmLayer "gray"
    @map.resetMap false, true
    
  # opportunitySelectedSegment: (projectId, segmentId) ->
  #   @reset(projectId)
  #   @routeNameKeeper 'opportunity'
  #   # @fetchProjectData
  #   @opportunityTab = new App.Views.OpportunityTab
  #     topBar: masterRouter.topBar
  #     projectId: projectId
  #     projects: masterRouter.projects
  #     segmentId: segmentId
  #   @map.setOsmLayer "gray"
  #   @map.resetMap false, true

  design: (projectId) ->
    @reset(projectId, 160)
    @routeNameKeeper 'design'
    # @fetchProjectData
    @designTab = new App.Views.DesignTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
    @map.setOsmLayer "gray"
    @map.resetMap false, true 
    
  help: (projectId) ->
    @reset(projectId)
    @routeNameKeeper 'help'
    new App.Views.HelpTab
      topBar: masterRouter.topBar
      projectId: projectId
      projects: masterRouter.projects
  
  routeNameKeeper: (routeName) ->
    @currentRouteName = routeName
    # if the current URL ends with an ID of the form c#
    # then we'll attach that after the route name
    if location.hash.split('/').pop().match(/c\d+/)
      @currentRouteName += ":" + location.hash.split('/').pop()
    
  reset: (projectId, topBarHeight = 90) ->
    ###
    TODO: if there are any map edits that have not yet been uploaded,
          kick the user back to map mode
    ###
    
    @clearTimers()
    
    if projectId
      masterRouter.projects.setCurrentProjectId projectId
    $('.modal').modal('hide').remove()
    $('.modal-backdrop').remove()
    masterRouter.topBarTabs = []
    masterRouter.modals = []
    $('#top-bar').animate {height:"#{topBarHeight}px"}, 400 unless $('#top-bar').height == topBarHeight 
    
  clearTimers: ->
    _.each @timers, (t) ->
      clearTimeout t
    @timers = []
      
  fetchProjectData: ->
    if masterRouter.geo_points.length == 0 or 
       masterRouter.geo_point_on_segments.length == 0 or
       masterRouter.segments.length == 0
      masterRouter.geo_points.fetch
        success: ->
          masterRouter.geo_point_on_segments.fetch
            success: -> 
              masterRouter.segments.fetch()
      masterRouter.model_jobs.fetch()
    if masterRouter.count_sessions.length == 0
      masterRouter.count_sessions.fetch()