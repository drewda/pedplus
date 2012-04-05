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

  getSegment: ->
    masterRouter.segments.get @get('segment_id')

  # get all CountSession's taken at this Gate
  getCountSessions: ->
    masterRouter.count_sessions.select (cs) ->
      cs.get('gate_id') == @id
    , this

  # return this Gate's GateGroup label along with its own label
  # for example: A-1
  printLabel: ->
    "#{@getGateGroup().get('label')}-#{@get('label')}"

  # check to see if there is a CountSession that was complete
  # at this Gate on a certain date, starting in a certain hour
  isCompletedFor: (date, hour) ->
    date = XDate date

    # return true if there is any CountSession that fits this criteria
    _.any @getCountSessions(), (cs) ->

      startDate = XDate cs.get('start')

      if startDate.getFullYear() == date.getFullYear() and
         startDate.getMonth() == date.getMonth() and
         startDate.getDate() == date.getDate() and
         startDate.getHours() == Number(hour.replace(/0/g, ''))
        return true