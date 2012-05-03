class App.Models.GateGroup extends Backbone.Model
  name: 'gate_group'

  getCountPlan: ->
    if @isNew()
      masterRouter.count_plans.getByCid @get('count_plan_cid')
    else
      masterRouter.count_plans.get @get('count_plan_id')

  # return the associated Gate's, which can be
  # local (with CID's) or from the server (with ID's)
  getGates: (includeMarkedForDelete = false) ->
    if includeMarkedForDelete
      if @isNew()
        masterRouter.gates.select (g) =>
          g.get('gate_group_cid') == @cid and g.get('markedForDelete') != true
      else
        masterRouter.gates.select (g) => 
          g.get('gate_group_id') == @id and g.get('markedForDelete') != true
    else
      if @isNew()
        masterRouter.gates.select (g) =>
          g.get('gate_group_cid') == @cid
      else
        masterRouter.gates.select (g) => 
          g.get('gate_group_id') == @id

  getDaysArray: ->
    @get('days').split ','
  getHoursArray: ->
    @get('hours').split ','

  # used in GateGroupTableRow
  printDays: ->
    daysArray = @getDaysArray()
    daysArray = _.map daysArray, (day) ->
      switch day
        when 'su' then 'Sunday'
        when 'mo' then 'Monday'
        when 'tu' then 'Tuesday'
        when 'we' then 'Wednesday'
        when 'th' then 'Thursday'
        when 'fr' then 'Friday'
        when 'sa' then 'Saturday'
    daysArray.join(', ')

  # used in GateGroupTableRow
  printHours: ->
    # note that we need to handle 1000 -> 10:00
    @get('hours').replace(/,/g, ', ').replace(/00/g, ':00').replace(/:000/, "0:00")

  # select a color from d3's set of 20 categorical colors
  # note that this effectively limits the number of CountGroup's in a CountPlan to 20!
  # see https://github.com/mbostock/d3/wiki/Ordinal-Scales#wiki-category20
  getColor: ->
    d3.scale.category20().domain(['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T'])(@get('label'))