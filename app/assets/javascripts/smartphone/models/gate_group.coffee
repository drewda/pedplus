class Smartphone.Models.GateGroup extends Backbone.Model
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
    @get('hours').replace(/,/g, ', ').replace(/00/g, ':00')

  # select a color from d3's set of 20 categorical colors
  # note that this effectively limits the number of CountGroup's in a CountPlan to 20!
  # see https://github.com/mbostock/d3/wiki/Ordinal-Scales#wiki-category20
  getColor: ->
    d3_category20 = [
      "#1f77b4"
      "#aec7e8"
      "#ff7f0e"
      "#ffbb78"
      "#2ca02c"
      "#98df8a"
      "#d62728"
      "#ff9896"
      "#9467bd"
      "#c5b0d5"
      "#8c564b"
      "#c49c94"
      "#e377c2"
      "#f7b6d2"
      "#7f7f7f"
      "#c7c7c7"
      "#bcbd22"
      "#dbdb8d"
      "#17becf"
      "#9edae5"
    ]

    index = @get('label').charCodeAt(0) - 'A'.charCodeAt(0)
    return d3_category20(index)