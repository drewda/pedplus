#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./connectors

window.Smartphone =
  Models: {}
  Collections: {}
  Views: {}
  init: ->
    # set up masterRouter 
    # using jQuery Mobile Router plugin: https://github.com/azicchetti/jquerymobile-router
    window.masterRouter = new $.mobile.Router [
      { "#open-project": { events: "s,i,c", handler: "openProject" } }
      { '#project(?:[?](.*))?': { events: "s", handler: "project" } }
      { "#count-session(?:[?](.*))?": { events: "s", handler: "countSession" } }
      ], 
        openProject: =>
          # clear for next time
          segments.reset()
          count_sessions.reset()
        project: (eventType, matchObj, ui, page, evt) =>
          console.log 'project'
          hashParams = getHashParams()
          if !hashParams.hasOwnProperty('projectId')
            window.location = '/smartphone'
          else if hashParams.projectId
            projectId = hashParams.projectId
            projects.setCurrentProjectId projectId
            projectPage = new Smartphone.Views.ProjectPage
              model: projects.getCurrentProject()
            # fetch Segment's and CountSession's because
            # we now have a currentProject defined
            segments.fetch() if segments.length == 0
            count_sessions.fetch() if count_sessions.length == 0
          # segment selected?
        countSession: (eventType, matchObj, ui, page, evt) =>
          console.log "countSession"
      , 
        ajaxApp: true

    # initialize and load Backbone collections
    window.projects = new Smartphone.Collections.Projects
    injectProjects() # projects will be injected by dashboard.slim
    # Segment's and CountSession's will be fetch'ed when the user selects a project
    window.segments = new Smartphone.Collections.Segments
    window.count_sessions = new Smartphone.Collections.CountSessions
$ ->
  window.Smartphone.init()