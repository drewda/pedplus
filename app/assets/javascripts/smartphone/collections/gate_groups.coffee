class Smartphone.Collections.GateGroups extends Backbone.Collection
  model: Smartphone.Models.GateGroup
  initialize: ->
    # when CountPlan's are updated, see if there is a current plan
    # and if so, fetch the appropriate GateGroup's
    masterRouter.count_plans.bind "reset", @fetchIfCurrentCountPlan, this

  # URL depends on there being a current CountPlan, 
  # so we wait until we know we have one
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/count_plans/#{masterRouter.count_plans.getCurrentCountPlan().id}/gate_groups"
  
  fetchIfCurrentCountPlan: ->
    @fetch() if masterRouter.count_plans.getCurrentCountPlan()
    # this fetch will trigger the fetching of the Gate collection