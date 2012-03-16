class App.Collections.CountPlans extends Backbone.Collection
  model: App.Models.CountPlan
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/count_plans"
  getCurrentCountPlan: ->
  	# TODO: select based on the is_the_current_plan boolean
  	@last()