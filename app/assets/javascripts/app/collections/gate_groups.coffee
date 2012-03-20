class App.Collections.GateGroups extends Backbone.Collection
  model: App.Models.GateGroup
  initialize: ->
    masterRouter.count_plans.bind "reset", @fetchIfCurrentCountPlan, this
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/count_plans/#{masterRouter.count_plans.getCurrentCountPlan().id}/gate_groups"
  fetchIfCurrentCountPlan: ->
    @fetch() if masterRouter.count_plans.getCurrentCountPlan()