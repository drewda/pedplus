class App.Collections.Projects extends Backbone.Collection
  initialize: ->
    @currentProjectId = 0
  model: App.Models.Project
  url: '/api/projects'
  setCurrentProjectId: (projectId) ->
    @currentProjectId = projectId
  getCurrentProjectId: ->
    return @currentProjectId
  getCurrentProject: ->
    @get(@currentProjectId) if @currentProjectId > 0