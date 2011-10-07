class App.Collections.ModelJobs extends Backbone.Collection
  model: App.Models.ModelJob
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/model_jobs"