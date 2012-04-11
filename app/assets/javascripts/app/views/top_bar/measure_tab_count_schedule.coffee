class App.Views.MeasureTabCountSchedule extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @countPlan = masterRouter.count_plans.getCurrentCountPlan()
    @date = @options.date
    @userId = @options.userId

    @countingSchedule = @countPlan.getCountingSchedule(@date, @userId)

    @topBar.render 'measure'
    @render()
  template: JST["app/templates/top_bar/measure_tab_count_schedule"]
  render: ->
    $('#tab-area').empty().html @template
      project: @options.projects.getCurrentProject()
      users: masterRouter.users
      countPlan: @countPlan
      countingSchedule: @countingSchedule
      date: @date

    # set the appropriate date in the drop-down select
    $('#measure-count-day-select').val @date

    # set the appropriate user in the drop-down select
    $('#measure-count-user-select').val @userId

    # bindings for drop-down selects
    $('#measure-count-day-select').on "change", $.proxy @measureCountSelectChange, this
    $('#measure-count-user-select').on "change", $.proxy @measureCountSelectChange, this

    # bindings for gate buttons
    $('.gate-to-count-button').on "click touchstart", @gateToCountButtonClick

  measureCountSelectChange: ->
    date = $('#measure-count-day-select').val()
    userId = $('#measure-count-user-select').val()
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count/schedule/date/#{date}/user/#{userId}", true

  gateToCountButtonClick: (event) ->
    # determine the appropriate Gate ID
    gateId = $(event.currentTarget).data('gate-id')
    # now navigate to MeasureTabCountStart to ask if user wants to start counting at that Gate
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count/start/gate/#{gateId}", true    