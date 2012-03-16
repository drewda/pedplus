class App.Routers.Master extends Backbone.Router
  initialize: (options) ->
    # this is how masterRouter will be referred to from other objects
    window.masterRouter = this
    
    # juggernaut connect to be used for push notifications
    # as when models are complete
    # @juggernautConnector = new JuggernautConnector
    
    ###
    # COLLECTIONS
    ###
    @projects = new App.Collections.Projects
    
    @users = new App.Collections.Users
    @users.fetch
      success: ->
        # masterRouter.juggernautConnector.subscribeToOrganization masterRouter.users.getCurrentUser().get('organization_id')
    
    # will be fetch'ed when the user selects a project
    # in project()
    @segments = new App.Collections.Segments
    @geo_points = new App.Collections.GeoPoints
    @geo_point_on_segments = new App.Collections.GeoPointOnSegments
    # will be fetch'ed in measure()
    @count_plans = new App.Collections.CountPlans
    @count_sessions = new App.Collections.CountSessions
    
    # will be populated by the client-side
    @map_edits = new App.Collections.MapEdits
    @model_jobs = new App.Collections.ModelJobs
    
    ###
    # VIEWS
    ###
    @spinner = new App.Views.Spinner
      
    @map = new App.Views.Map
      projects: @projects
    @topBar = new App.Views.TopBar
    @topBarTabs = []
    @modals = []
    @projectTab = null
    @mapTab = null
    @modelTab = null
    @measureTab = null
    @opportunityTab = null
    @designTab = null
    
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
    
    ### 
    # GLOBAL SESSION VARIABLES
    # default values will be set in projectOpen()
    ###
    # used in DeleteGeoPointModal and DeleteSegmentModal
    @hideDeleteGeoPointConfirmation = null
    @hideDeleteSegmentConfirmation = null
    # used in MeasureTab
    @mostRecentMeasureSubTab = null

    # we'll store the current route name using routeNameKeeper()
    @currentRouteName = ""
    
    @timers = []

  routes:
    ".*" : "index"
    
    "project/open"                  : "projectOpen"
    "project/:project_id"           : "project"
    "project/:project_id/settings"  : "projectSettings"
    "project/:project_id/export"    : "projectExport"
    
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

    "project/:project_id/measure"                                             : "measure"

    "project/:project_id/measure/plan"                                        : "measurePlan"
    "project/:project_id/measure/plan/assistant"                              : "measurePlanAssistant"
    "project/:project_id/measure/plan/segment_id/:segment_id"                 : "measurePlanSelectedSegment"
    "project/:project_id/measure/plan/count_session/:count_session_id"        : "measurePlanSelectedCountSession"
    "project/:project_id/measure/plan/count_session/:count_session_id/edit"   : "measurePlanEditCountSession"

    "project/:project_id/measure/count"                                       : "measureCount"
    "project/:project_id/measure/count/count_session/new"                     : "measureCountNewCountSession"
    "project/:project_id/measure/count/count_session/:count_session_id/enter" : "measureCountEnterCountSession"
    "project/:project_id/measure/count/count_session/:count_session_id"       : "measureCountSelectedCountSession"

    "project/:project_id/measure/view"                                        : "measureView"
    "project/:project_id/measure/view/segment/:segment_id"                    : "measureViewSelectedSegment"
    "project/:project_id/measure/view/count_session/:count_session_id"        : "measureViewSelectedCountSession"
    
    "project/:project_id/opportunity"             : "opportunity"
    # "project/:project_id/opportunity/:segment_id" : "opportunitySelectedSegment"

    "project/:project_id/design"                              : "design"
    # "project/:project_id/design/scenario/new"                 : "designScenarioNew"
    # "project/:project_id/design/scenario/edit/:scenario_id}"  : "designScenarioEdit"
    "project/:project_id/design/scenario/:scenario_id}"       : "designScenarioView"
    
    "project/:project_id/help" : "help"

  index: ->
    masterRouter.navigate 'project/open', true

  projectOpen: ->
    # clear tab bar
    if @projectTab
      @projectTab.remove()
    $('#top-bar').hide() # will be shown again in project()

    # clear data from previously used project
    masterRouter.projects.reset()
    masterRouter.geo_points.reset()
    masterRouter.geo_point_on_segments.reset()
    masterRouter.segments.reset()
    # projects will be injected by dashboard.slim
    injectProjects()

    # reset global session variables
    @hideDeleteGeoPointConfirmation = false
    @hideDeleteSegmentConfirmation = false
    @mostRecentMeasureSubTab = null

    @routeNameKeeper 'projectOpen'
    @reset()
    projectsModal = new App.Views.ProjectsModal
      mode: "open"
      projects: masterRouter.projects
    masterRouter.modals.push projectsModal
    @map.setOsmLayer "color"
    @map.resetMap false, false
    @map.centerMap()

  project: (projectId) ->
    if @reset(projectId)
      @routeNameKeeper 'project'
      $('#top-bar').show() # was hidden in projectOpen()

      # fetch project data
      if masterRouter.geo_points.length == 0 or 
         masterRouter.geo_point_on_segments.length == 0 or
         masterRouter.segments.length == 0 or
         masterRouter.count_sessions.length == 0 or
         masterRouter.count_plans.length == 0
        masterRouter.geo_points.fetch
          success: ->
            masterRouter.geo_point_on_segments.fetch
              success: -> 
                masterRouter.segments.fetch
                  success: ->
                    masterRouter.count_sessions.fetch()
                    masterRouter.count_plans.fetch()
        masterRouter.model_jobs.fetch()

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
    if @reset(projectId)  
      @routeNameKeeper 'projectSettings'
      @projectTab = new App.Views.ProjectTab
        topBar: masterRouter.topBar
        projectId: projectId
        projects: masterRouter.projects
      projectModal = new App.Views.ProjectModal
        mode: "settings"
        project: masterRouter.projects.getCurrentProject()
      masterRouter.modals.push projectModal

  projectExport: (projectId) ->
    if @reset(projectId)  
      @routeNameKeeper 'projectExport'
      @projectTab = new App.Views.ProjectTab
        topBar: masterRouter.topBar
        projectId: projectId
        projects: masterRouter.projects
      projectModal = new App.Views.ProjectModal
        mode: "export"
        project: masterRouter.projects.getCurrentProject()
      masterRouter.modals.push projectModal
  
  map: (projectId) ->
    if @reset(projectId)
      @routeNameKeeper 'map'
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
    if @reset(projectId)
      @routeNameKeeper 'mapSelectedGeoPoint'
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
    if @reset(projectId)
      @routeNameKeeper 'mapMoveGeoPoint'
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
    if @reset(projectId)
      @routeNameKeeper 'mapConnectGeoPoint'
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
    if @reset(projectId)
      @routeNameKeeper 'mapDeleteGeoPoint'
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
    if @reset(projectId)
      @routeNameKeeper 'mapSelectedSegment'
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
    if @reset(projectId)
      @routeNameKeeper 'mapDeleteSegment'
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
    if @reset(projectId)
      @routeNameKeeper 'mapUploadEdits'
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
    if @reset(projectId)
      @routeNameKeeper 'model'
      @modelTab = new App.Views.ModelTab
        topBar: masterRouter.topBar
        projectId: projectId
        projects: masterRouter.projects
        mode: "model"
      @map.setOsmLayer "gray"
      @map.resetMap false, true
      masterRouter.segments.selectNone()
    
  modelPermeability: (projectId, modelJobId) ->
    if @reset(projectId)
      @routeNameKeeper 'modelPermeability'
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
    # redirect to the most recently used sub tab,
    # or just redirect to view sub tab, as that one
    # is available to all users
    if @mostRecentMeasureSubTab == "plan"
      masterRouter.navigate "#project/#{@projects.getCurrentProjectId()}/measure/plan", true
    else if @mostRecentMeasureSubTab == "count"
      masterRouter.navigate "#project/#{@projects.getCurrentProjectId()}/measure/count", true
    else
      masterRouter.navigate "#project/#{@projects.getCurrentProjectId()}/measure/view", true

  measurePlan: (projectId) ->
    if @reset(projectId, true, 250)
      @routeNameKeeper 'measurePlan'
      @mostRecentMeasureSubTab = "plan"
      @measureTab = new App.Views.MeasureTab
        topBar: masterRouter.topBar
        projectId: projectId
        projects: masterRouter.projects
        mode: "measurePlan"
      @map.setOsmLayer "gray"
      @map.resetMap false, true
      @geo_points.selectNone()
      @segments.selectNone()

  measurePlanAssistant: (projectId) ->
    if @reset(projectId, false, 285)
      @routeNameKeeper 'measurePlanAssistant'
      @measureTab = new App.Views.MeasureTab
        topBar: masterRouter.topBar
        users: masterRouter.users
        projectId: projectId
        projects: masterRouter.projects
        mode: "measurePlanAssistant"
      @map.setOsmLayer "gray"
      @map.resetMap false, true
      @geo_points.selectNone()
      @segments.selectNone()

  measurePlanSelectedSegment: (projectId, segmentId) ->
    # TODO

  measurePlanSelectedCountSession: (projectId, countSessionId) ->
    # TODO

  measurePlanEditCountSession: (projectId, countSessionId) ->
    # TODO

  measureCount: (projectId) ->
    if @reset(projectId, true, 250)
      @routeNameKeeper 'measureCount'
      @mostRecentMeasureSubTab = "count"
      @measureTab = new App.Views.MeasureTab
        topBar: masterRouter.topBar
        projectId: projectId
        projects: masterRouter.projects
        mode: "measureCount"
      @map.setOsmLayer "gray"
      @map.resetMap false, true
      @geo_points.selectNone()
      @segments.selectNone()

  measureCountNewCountSession: (projectId) ->
    # TODO

  measureCountEnterCountSession: (projectId) ->
    # TODO

  measureCountSelectedCountSession: (projectId, countSessionId) ->
    # TODO

  measureView: (projectId) ->
    if @reset(projectId, true, 250)
      @routeNameKeeper 'measureView'
      @mostRecentMeasureSubTab = "view"
      @measureTab = new App.Views.MeasureTab
        topBar: masterRouter.topBar
        projectId: projectId
        projects: masterRouter.projects
        mode: "measureView"
      @map.setOsmLayer "gray"
      @map.resetMap false, true
      @geo_points.selectNone()
      @segments.selectNone()
      if !@countSessionTable
        @countSessionTable = new App.Views.CountSessionTable
          count_sessions: masterRouter.count_sessions
      else
        @countSessionTable.render()

  measureViewSelectedSegment: (projectId) ->
    if @reset(projectId, true, 250)
      @routeNameKeeper 'measureViewSelectedSegment'

  measureViewSelectedCountSession: (projectId) ->
    if @reset(projectId, true, 250)
      @routeNameKeeper 'measureViewSelectedCountSession'
  
  # measurePredictions: (projectId) ->
  #   @reset(projectId, 580)
  #   @routeNameKeeper 'measurePredictions'
  #   @measureTab = new App.Views.MeasureTab
  #     topBar: masterRouter.topBar
  #     projectId: projectId
  #     projects: masterRouter.projects
  #     mode: "predictions"
  #   @map.setOsmLayer "gray"
  #   @map.resetMap false, true  
  #   @geo_points.selectNone()
  #   @segments.selectNone()
      
  # measureNewCountSession: (projectId, segmentId) ->
  #   @reset(projectId, 250)
  #   @routeNameKeeper 'measureNewCountSession'
  #   @measureTab = new App.Views.MeasureTab
  #     topBar: masterRouter.topBar
  #     projectId: projectId
  #     projects: masterRouter.projects
  #     segmentId: segmentId
  #   newCountSessionModal = new App.Views.NewCountSessionModal
  #     projectId: projectId
  #     segmentId: segmentId
  #   masterRouter.modals.push newCountSessionModal
  #   if !@countSessionTable
  #     @countSessionTable = new App.Views.CountSessionTable
  #       count_sessions: masterRouter.count_sessions
  #   else
  #     @countSessionTable.render()
      

  # measureEnterCountSession: (projectId, countSessionId) ->
  #   @reset(projectId, true, 160)
  #   @routeNameKeeper 'measureEnterCountSession'
  #   if @countSessionTable
  #     @countSessionTable.remove()
  #   @measureTab = new App.Views.MeasureTab
  #     topBar: masterRouter.topBar
  #     projectId: projectId
  #     projects: masterRouter.projects
  #     countSessionId: countSessionId
  #     mode: "enterCountSession"

  opportunity: (projectId) ->
    if @reset(projectId, true, 580)
      @routeNameKeeper 'opportunity'
      @opportunityTab = new App.Views.OpportunityTab
        topBar: masterRouter.topBar
        projectId: projectId
        projects: masterRouter.projects
      @map.setOsmLayer "gray"
      @map.resetMap false, true
    
  # opportunitySelectedSegment: (projectId, segmentId) ->
  #   @reset(projectId)
  #   @routeNameKeeper 'opportunity'
  #   @opportunityTab = new App.Views.OpportunityTab
  #     topBar: masterRouter.topBar
  #     projectId: projectId
  #     projects: masterRouter.projects
  #     segmentId: segmentId
  #   @map.setOsmLayer "gray"
  #   @map.resetMap false, true

  design: (projectId) ->
    if @reset(projectId)
      @routeNameKeeper 'design'
      @designTab = new App.Views.DesignTab
        topBar: masterRouter.topBar
        projectId: projectId
        projects: masterRouter.projects
      @map.setOsmLayer "color"
      @map.resetMap false, true 
    
  help: (projectId) ->
    if @reset(projectId)
      @routeNameKeeper 'help'
      new App.Views.HelpTab
        topBar: masterRouter.topBar
        projectId: projectId
        projects: masterRouter.projects
  
  routeNameKeeper: (routeName) ->
    @currentRouteName = routeName
    # if the current URL ends with an ID of the form c#
    # or # then we'll attach that after the route name
    if location.hash.split('/').pop().match(/c\d+/) or
       location.hash.split('/').pop().match(/\d+/)
      @currentRouteName += ":" + location.hash.split('/').pop()
    
  reset: (projectId = null, clearScreen = true, topBarHeight = 80) ->
    ###
    TODO: if there are any map edits that have not yet been uploaded,
          kick the user back to map mode
    ###

    @clearTimers()

    # if projects have not yet been loaded, kick the user back to the start
    if @projects.length < 1
      masterRouter.navigate '#', true
      return false # do not continue with any more page setup
    else      
      if projectId
        masterRouter.projects.setCurrentProjectId projectId
      if clearScreen
        $('.modal').modal('hide').remove()
        $('.modal-backdrop').remove()
        masterRouter.topBarTabs = []
        masterRouter.modals = []
      $('#top-bar').animate {height:"#{topBarHeight}px"}, 400 unless $('#top-bar').height == topBarHeight 
      return true # continue with the rest of the page setup
    
  clearTimers: ->
    _.each @timers, (t) ->
      clearTimeout t
    @timers = []