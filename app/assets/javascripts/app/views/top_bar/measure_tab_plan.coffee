class App.Views.MeasureTabPlan extends Backbone.View
  initialize: ->
    # render the top bar
    @topBar = @options.topBar
    @topBar.render 'measure'

    # get ready to render GateGroupTableRow's
    gateGroupTableRows = []

    # select the current CountPlan
    @countPlan = masterRouter.count_plans.getCurrentCountPlan()
    # or prepare to create a new one locally
    if not @countPlan
      # Create the new CountPlan record with the default values.

      @countPlan = new App.Models.CountPlan
        project_id: masterRouter.projects.getCurrentProjectId()
        total_weeks: 1
        count_session_duration_seconds: 10 * 60 # 10 minutes
        is_the_current_plan: true
        start_date: @nextMonday()
      # add to the CountPlan collection
      masterRouter.count_plans.add @countPlan
      # and now redirect to MeasureTabPlanEdit
      masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan/#{@countPlan.cid}/edit", true

    # assuming there is a current CountPlan
    else
      # render the MeasureTabPlan tab
      @render()

      # now render all the GateGroupTableRow's
      _.each @countPlan.getGateGroups(), (gg) ->
        gateGroupTableRow = new App.Views.GateGroupTableRow
          gateGroup: gg
          mode: "show"
        gateGroupTableRows.push gateGroupTableRow
      , this
      # and remove all the buttons to edit GateGroup's
      $('.edit-gate-group-button').remove()

  template: JST["app/templates/top_bar/measure_tab_plan"]

  render: ->
    # render the template
    $('#tab-area').empty().html @template
      project: @options.projects.getCurrentProject()
      users: @options.users
      countPlan: @countPlan

    # bind button actions
    $('#archive-count-plan-button').on "click", $.proxy @archiveCountPlanButton, this
    $('#edit-count-plan-button').on "click", $.proxy @editCountPlanButton, this

  archiveCountPlanButton: ->
    bootbox.confirm "Are you sure you want to archive this count plan? It will no longer be visible to counters.", (confirmed) =>
      if confirmed
        @countPlan.save
          is_the_current_plan: false
        ,
          success: ->
            masterRouter.countPlan.fetch
              success: ->
                masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/view", true
          error: ->
            bootbox.alert "Error updating the count plan on the server. Please start over.", (ok) =>
              window.location.reload()

  editCountPlanButton: ->
    # TODO
    bootbox.alert "This functionality has not yet been implemented."

  nextMonday: ->
    # start with today
    date = XDate()
    # if today is a Monday, just return today
    return date if date.getDay() == 1
    # or keep adding days until the date is a Monday
    date.addDays(1) until date.getDay() == 1
    return date