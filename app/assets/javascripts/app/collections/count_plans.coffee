class App.Collections.CountPlans extends Backbone.Collection
  model: App.Models.CountPlan
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/count_plans"
  getCurrentCountPlan: ->
    @detect (cp) => cp.get('is_the_current_plan')
  getArchivedCountPlans: ->
    @filter (cp) => !cp.get('is_the_current_plan')