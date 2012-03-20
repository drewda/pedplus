class App.Collections.Gates extends Backbone.Collection
  model: App.Models.Gate
  initialize: ->
    masterRouter.count_plans.bind "reset", @fetchIfCurrentCountPlan, this
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/count_plans/#{masterRouter.count_plans.getCurrentCountPlan().id}/gates"
  fetchIfCurrentCountPlan: ->
    @fetch() if masterRouter.count_plans.getCurrentCountPlan()