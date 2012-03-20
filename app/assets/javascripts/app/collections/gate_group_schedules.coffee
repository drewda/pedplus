class App.Collections.GateGroupSchedules extends Backbone.Collection
  model: App.Models.GateGroupSchedule
  initialize: ->
    masterRouter.count_plans.bind "reset", @fetchIfCurrentCountPlan, this
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/count_plans/#{masterRouter.count_plans.getCurrentCountPlan().id}/gate_group_schedules"
  fetchIfCurrentCountPlan: ->
    @fetch() if masterRouter.count_plans.getCurrentCountPlan()