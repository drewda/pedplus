class App.Models.CountPlan extends Backbone.Model
  name: 'count_plan'

  initialize: ->
    # listen for removals of GateGroups and then redo label letters 
    # (which will in turn update colors) for GateGroup's
    masterRouter.gate_groups.bind "remove", @updateGateGroupLabels, this
    masterRouter.gate_groups.bind "change", @updateGateGroupLabels, this

  # return the associated GateGroup's, which can be
  # local (with CID's) or from the server (with ID's)
  getGateGroups: (includeMarkedForDelete = false) ->
    if includeMarkedForDelete
      if @isNew()
        masterRouter.gate_groups.select (gg) =>
          gg.get('count_plan_cid') == @cid and gg.get('markedForDelete') != true
      else
        masterRouter.gate_groups.select (gg) => 
          gg.get('count_plan_id') == @id and gg.get('markedForDelete') != true
    else
      if @isNew()
        masterRouter.gate_groups.select (gg) =>
          gg.get('count_plan_cid') == @cid
      else
        masterRouter.gate_groups.select (gg) => 
          gg.get('count_plan_id') == @id

  # compute the end date
  getEndDate: ->
    startDate = new XDate @get 'start_date'
    endDate = startDate.addWeeks numberOfWeeks
    endDate = startDate.addDays 6

  # does the CountPlan last for a singular or plural
  # number of weeks?
  printWeeks: ->
    string = @get 'weeks'
    if string != 1
      string += ' weeks'
    else
      string += ' week'

  # add a new GateGroup, with default values
  addNewGateGroup: ->
    if @getGateGroups().length > 0
      nextLabel = @nextLetter @lastLabel()
    else
      nextLabel = 'A'

    if @isNew()
      gateGroup = new App.Models.GateGroup
        count_plan_cid: @cid
        label: nextLabel
        days: 'tu,th,sa,su'
        hours: '700,800,900,1200,1300,1600,1700,1800,1900'
        status: 'proposed'
    else
      gateGroup = new App.Models.GateGroup
        count_plan_id: @id
        label: nextLabel
        days: 'tu,th,sa,su'
        hours: '700,800,900,1200,1300,1600,1700,1800,1900'
        status: 'proposed'

    masterRouter.gate_groups.add gateGroup

    return gateGroup

  # listen for removals of GateGroups and then redo label letters 
  # (which will in turn update colors) for GateGroup's
  updateGateGroupLabels: ->
    # sort by label
    gateGroups = _.sortBy @getGateGroups(), (gg) ->
      gg.get 'label'
    # now update the labels in sequence: A, B, C...
    lastLabel = ''
    _.each gateGroups, (gg) ->
      if lastLabel == ''
        label = 'A'
      else
        label = @nextLetter lastLabel
      gg.set
        label: label
      lastLabel = label
    , this

  # which was the last letter used to label a GateGroup
  # in this CountPlan?
  lastLabel: ->
    lastGG = _.max @getGateGroups(), (gg) -> 
      gg.get('label').charCodeAt()
    lastGG.get 'label'

  # what is the next letter in the alphabet?
  # note that this will fail at letter Z
  # code from http://stackoverflow.com/a/2256724/40956
  nextLetter: (s) ->
    s.replace /([a-zA-Z])[^a-zA-Z]*$/, (a) ->
      c = a.charCodeAt 0
      switch c
        when 90 then 'A'
        when 122 then 'a'
        else String.fromCharCode ++c