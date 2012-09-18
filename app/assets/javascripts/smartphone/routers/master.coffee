class Smartphone.Routers.Master extends Backbone.Router
  initialize: (options) ->
    # set up masterRouter 
    # using jQuery Mobile Router plugin: https://github.com/azicchetti/jquerymobile-router
    window.masterRouter = new $.mobile.Router [
      { "#open-project": { events: "s,i,c", handler: "openProject" } }
      { '#show-count-schedule(?:[?](.*))?': { events: "s", handler: "showCountSchedule" } }
      { "#start-count(?:[?](.*))?": { events: "s", handler: "startCount" } }
      { "#enter-count(?:[?](.*))?": { events: "s", handler: "enterCount" } }
      { "#validate-count(?:[?](.*))?": { events: "s", handler: "validateCount" } }
      ], 
        openProject: =>
          # clear collections for when we switch to another project
          masterRouter.segments.reset()
          masterRouter.count_sessions.reset()
          masterRouter.gates.reset()
          masterRouter.gate_groups.reset()
          masterRouter.count_plans.reset()

        showCountSchedule: (eventType, matchObj, ui, page, evt) =>
          hashParams = getHashParams()
          if masterRouter.reset(hashParams, ['projectId'])
            $.mobile.showPageLoadingMsg()
            # TODO: do something while those collections are being fetched from the server
            # fetch Segment's and CountSession's because
            # we now have a currentProject defined
            masterRouter.segments.fetch
              success: ->
                masterRouter.count_plans.fetch
                  success: ->
                    masterRouter.count_sessions.fetch
                      success: ->
                        if masterRouter.count_plans.getCurrentCountPlan()
                          # we need to fetch GateGroup's because that's needed for CountPlan.getAllUserIds()
                          # maybe in the future this is a method to move to the server-side
                          masterRouter.gate_groups.fetch
                            success: ->
                              $.mobile.hidePageLoadingMsg()
                              masterRouter.showCountSchedulePage = new Smartphone.Views.ShowCountSchedulePage
                                model: masterRouter.projects.getCurrentProject()
                                date: hashParams.date
                                userId: hashParams.userId
                        else
                          $.mobile.hidePageLoadingMsg()
                          # if there is no current count plan for this project, 
                          # send the user back to select a different project
                          window.history.back()

        startCount: (eventType, matchObj, ui, page, evt) =>
          hashParams = getHashParams()
          if masterRouter.reset(hashParams, ['projectId', 'gateId'])
            masterRouter.startCountPage = new Smartphone.Views.StartCountPage
              gate: masterRouter.gates.get(hashParams.gateId)

        enterCount: (eventType, matchObj, ui, page, evt) =>
          hashParams = getHashParams()
          if masterRouter.reset(hashParams, ['projectId', 'countSessionCid'])
            masterRouter.enterCountPage = new Smartphone.Views.EnterCountPage
              countSessionCid: hashParams.countSessionCid

        validateCount: (eventType, matchObj, ui, page, evt) =>
          hashParams = getHashParams()
          if masterRouter.reset(hashParams, ['projectId', 'countSessionCid'])
            masterRouter.validateCountPage = new Smartphone.Views.ValidateCountPage
              countSessionCid: hashParams.countSessionCid
      , 
        ajaxApp: true

    # initialize and load Backbone collections
    masterRouter.projects = new Smartphone.Collections.Projects
    injectProjects() # projects will be injected by dashboard.slim
    masterRouter.users = new Smartphone.Collections.Users
    injectUsers() # users will be injected by dashboard.slim

    # will be fetch'ed when the user selects a project
    masterRouter.segments = new Smartphone.Collections.Segments
    masterRouter.count_plans = new Smartphone.Collections.CountPlans
    masterRouter.gate_groups = new Smartphone.Collections.GateGroups
    masterRouter.gates = new Smartphone.Collections.Gates
    masterRouter.count_sessions = new Smartphone.Collections.CountSessions

    # timers array (which will be used by EnterCountPage)
    masterRouter.timers = []

    masterRouter.clearTimers = ->
      _.each @timers, (t) ->
        clearInterval t
      @timers = []

    masterRouter.reset = (hashParams, hashParamsExpected) ->
      # check to make sure each of the expected hash parameters are there
      _.each hashParamsExpected, (hashParam) ->
        # if one is not there, go back to the start
        if not hashParams.hasOwnProperty(hashParam)
          window.location = '/smartphone'
          return false
      # if we didn't send the user back to the start, 
      # we can now set the current project ID
      projectId = hashParams.projectId
      masterRouter.projects.setCurrentProjectId projectId
      return true