class App.Views.CountPlanTableRow extends Backbone.View
  initialize: ->
    @gateGroup = @options.gateGroup
    @mode = @options.mode

    @render()
  template: JST["app/templates/tables/count_plan_table_row"]
  render: ->
    $('#count-plan-table tbody').append @template
      gateGroup: @gateGroup
      users: masterRouter.users
      mode: @mode

    if @mode == "show"
      $('.edit-gate-group-button').bind "click", (event) ->
        # TODO
        console.log "clicked edit botton"

    else if @mode == "edit" || @mode == "new"
      # select day checkboxes
      _.each @gateGroup.getDaysArray(), (day) ->
        $("##{day}-checkbox").prop 'checked', true

      # select hour checkboxes
      _.each @gateGroup.getHoursArray(), (hour) ->
        $("##{hour}-checkbox").prop 'checked', true

      $('.remove-gate-group-button').bind "click", (event) ->
        # TODO
      $('.save-gate-group-button').bind "click", (event) ->
        # TODO