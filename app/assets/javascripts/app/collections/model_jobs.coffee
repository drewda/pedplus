class App.Collections.ModelJobs extends Backbone.Collection
  model: App.Models.ModelJob
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/model_jobs"
  getModelsForCurrentVersion: (kind = "*") ->
    @filter (mj) =>
      if mj.get('finished')
        if mj.get('project_version') == masterRouter.projects.getCurrentProject().get('version')
          if kind == "*"
            return true
          else
            return mj.get('kind') == kind