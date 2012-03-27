class App.Models.Gate extends Backbone.Model
  name: 'gate'

  getGateGroup: ->
    if @isNew()
      masterRouter.gate_groups.getByCid @get('gate_group_cid')
    else
      masterRouter.gate_groups.get @get('gate_group_id')

  getCountPlan: ->
    if @isNew()
      masterRouter.count_plans.getByCid @get('count_plan_cid')
    else
      masterRouter.count_plans.get @get('count_plan_id')