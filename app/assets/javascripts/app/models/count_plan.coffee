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

  # return all the associated Gate's
  getGates: (includeMarkedForDelete = false) ->
    if includeMarkedForDelete
      if @isNew()
        masterRouter.gates.select (g) =>
          g.get('count_plan_cid') == @cid and g.get('markedForDelete') != true
      else
        masterRouter.gates.select (g) => 
          g.get('count_plan_id') == @id and g.get('markedForDelete') != true
    else
      if @isNew()
        masterRouter.gates.select (g) =>
          g.get('count_plan_cid') == @cid
      else
        masterRouter.gates.select (g) => 
          g.get('count_plan_id') == @id

  # compute the end date
  getEndDate: ->
    startDate = new XDate @get 'start_date'
    endDate = startDate.addWeeks @get 'total_weeks'
    endDate = endDate.addDays -1

  # Return an array with all the dates within the CountPlan.
  # This will be used for MeasureTabCount
  getAllDates: ->
    dates = []
    date = new XDate @get 'start_date' 
    while date <= @getEndDate()
      dates.push date.clone()
      date = date.addDays 1
    return dates

  # return id's for all the User's who are listed as counters in this CountPlan
  getAllUserIds: ->
    _.uniq _.map @getGateGroups(), (gg) -> gg.get 'user_id'

  # Produce a counting schedule for a certain date and user. For example:
  # [
  #   {
  #     'hour': '700',
  #     'gateGroupLetter': 'A',
  #     'gates':
  #       [
  #         {
  #           'segment_id': '3323',
  #           'label': 'A-1',
  #           'completed': false
  #         }
  #       ]
  #   },
  # ]
  # This function is used by MeasureTabCountSchedule
  getCountingSchedule: (date, userId) ->
    gateGroups = @getGateGroupsFor(date, userId)

    daySchedule = []

    for gateGroup in gateGroups
      for hour in gateGroup.get('hours').split(',')
        gates = []
        for gate in gateGroup.getGates()
          gateSchedule =
            segmentId: gate.get('segment_id')
            gateId: gate.id
            label: gate.get('label')
            completed: gate.isCompletedFor(date, hour)
          gates.push gateSchedule
        hourSchedule =
          hour: hour.replace('00',':00')
          gateGroupLetter: gateGroup.get('label')
          gates: gates
        daySchedule.push hourSchedule

    return daySchedule

  # This function is used by SegmentLayer to determine which Segment's
  # to draw on the map. Will return a set of Segment ID's.
  getGatesFor: (date, userId) ->
    segmentIds = []
    for gateGroup in @getGateGroupsFor(date, userId)
      for gate in gateGroup.getGates()
        segmentIds.push gate.get('segment_id')
    return segmentIds

  # Return the GateGroup's for a certain date and user ID.
  # This function is used by @getCountingSchedule()
  getGateGroupsFor: (date, userId) ->
    # we're going to use the XDate library
    date = new XDate(date)

    # first filter GateGroup's by user ID
    gateGroups = _.select @getGateGroups(), (gg) -> 
      gg.get('user_id') == Number(userId)

    # set up to filter by day of the week
    switch date.getDay()
      when 0 then day = 'su'
      when 1 then day = 'mo'
      when 2 then day = 'tu'
      when 3 then day = 'we'
      when 4 then day = 'th'
      when 5 then day = 'fr'
      when 6 then day = 'sa'

    # now filter by day of the week
    gateGroups = _.select gateGroups, (gg) ->
      gg.get('days').match(day)

    # and finally make sure that this date is within
    # the date range of this overall CountPlan
    if date > XDate(@get 'start_date') and
       date < XDate(@get 'end_date')
      return gateGroups
    # if it isn't within the date range, just return an empty array
    else
      return []

  # does the CountPlan last for a singular or plural
  # number of weeks?
  printWeeks: ->
    string = @get 'total_weeks'
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