class App.Views.GateGroupTableRow extends Backbone.View
  initialize: ->
    @gateGroup = @options.gateGroup
    @mode = @options.mode

    @render()
  template: JST["app/templates/tables/gate_group_table_row"]
  render: ->
    $('#gate-group-table tbody').append @template
      gateGroup: @gateGroup
      users: masterRouter.users
      projects: masterRouter.projects
      mode: @mode

    if @mode == "edit"
      # when checkboxes are checked, make the label bold
      $(':checkbox').change ->
        if $(this).prop 'checked'
          $(this).parent().css 'font-weight', 'bold'
        else
          $(this).parent().css 'font-weight', 'normal'

      # mark the appropriate day checkboxes
      # and make their labels bold
      _.each @gateGroup.getDaysArray(), (day) ->
        $("##{day}-checkbox").prop 'checked', true
        $("##{day}-checkbox").parent().css 'font-weight', 'bold'

      # mark the appropriate hour checkboxes
      # and make their labels bold
      _.each @gateGroup.getHoursArray(), (hour) ->
        $("##{hour}-checkbox").prop 'checked', true
        $("##{hour}-checkbox").parent().css 'font-weight', 'bold'

      # select the appropriate segments
      _.each @gateGroup.getGates(), (gate) ->
        masterRouter.segments.get(gate.get 'segment_id').doSelect(true)
      # note that by using deSelect() we are bypassing the check on select()
      # that makes sure we aren't selecting a segment that is already a gate

      # bind the button actions
      $('#auto-select-gates-button').click $.proxy @autoSelectGatesButton, this
      $('#remove-gate-group-button').click $.proxy @removeGateGroupButton, this
      $('#save-gate-group-button').click $.proxy @saveGateGroupButton, this

  autoSelectGatesButton: (event) ->
    # TODO
    bootbox.alert "This feature does not yet work."

  removeGateGroupButton: (event) ->
    bootbox.confirm "Are you sure you want to remove this gate group?", (confirmed) =>
      if confirmed
        # if it's a local GateGroup, we just remove it locally
        if @gateGroup.isNew()
          masterRouter.gate_groups.remove @gateGroup
          masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan/#{masterRouter.count_plans.getCurrentCountPlan().cid}/edit", true
        # or if it's from the server, we'll have to mark it for deleting later
        # (when the user presses the button to save the CountPlan)
        else
          @gateGroup.set
            markedForDelete: true
            masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan/#{masterRouter.count_plans.getCurrentCountPlan().cid}/edit", true
        # note that if this is the only GateGroup, then a new initial GateGroup will immediately be created (locally)
        # which means there is no way to have a CountPlan without any GateGroup's

  saveGateGroupButton: (event) ->
    # validate that 5 segments have been selected
    # if not, show alert and stop the save process
    if masterRouter.segments.selected().length != 5
      bootbox.alert "Please select five segments to include as gates in this gate group."
      return
    # validate that at least one day has been checked
    if $('.day-checkbox:checked').length == 0
      bootbox.alert "Please select at least one day for this gate group."
      return
    # validate that at least one hour has been checked
    if $('.hour-checkbox:checked').length == 0
      bootbox.alert "Please select at least one hour for this gate group."
      return

    # which user is selected?
    userId = $('.gate-group-counter-select').val()

    # which days have been checked?
    daysArray = $('.day-checkbox:checked').map -> $(this).val()
    daysArray = daysArray.get() # convert from jQuery object to array
    daysString = daysArray.join() # convert to a comma-separated string

    # which hours have been checked?
    hoursArray = $('.hour-checkbox:checked').map -> $(this).val()
    hoursArray = hoursArray.get() # convert from jQuery object to array
    hoursString = hoursArray.join() # convert to a comma-separated string

    # set the GateGroup's new values
    @gateGroup.set
      user_id: userId
      days: daysString
      hours: hoursString

    # remove the GateGroup's existing Gates
    _.each @gateGroup.getGates(), (gate) ->
      if gate.isNew()
        masterRouter.gates.remove gate
      else
        gate.set
          markedForDelete: true

    # create new Gates for the selected segments
    _.each masterRouter.segments.selected(), (segment) ->
      # create the Gate
      gate = new App.Models.Gate
        segment_id: segment.id
        gate_group_cid: @gateGroup.cid
        gate_group_id: @gateGroup.id # TODO: check
        count_plan_cid: @gateGroup.get 'count_plan_cid'
        count_plan_id: @gateGroup.get 'count_plan_id' # TODO: check
      # and add to the Gate collection
      masterRouter.gates.add gate
    , this

    # now deselect those segments
    masterRouter.segments.selectNone()

    # make sure to reload the segment layer, in order to display proper coloring
    masterRouter.segment_layer.layer.reload()

    # the changes to GateGroup's and Gate's will actually be uploaded
    # to the server when/if the user presses the Save button

    # switch to showing the GateGroupTableRow
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan/#{@gateGroup.getCountPlan().cid}/edit", true