class Smartphone.Views.CountingScheduleListview extends Backbone.View
  el: '#counting-schedule-listview'
  initialize: ->
    @date = @options.date
    @userId = @options.userId
    @countPlan = masterRouter.count_plans.getCurrentCountPlan()
    @project = masterRouter.projects.getCurrentProject()

    @countingSchedule = @countPlan.getCountingSchedule(@date, @userId)

    @render()
  render: ->
    $(@el).empty()
    _.each @countingSchedule, (hour) =>
      $(@el).append "<li data-role='list-divider'>Gate Group Starting at #{hour.hour}</li>"
      _.each hour.gates, (gate) =>
        if gate.completed
          $(@el).append "<li data-theme='e' data-icon='check'><a>Gate #{hour.gateGroupLetter}-#{gate.label} <span class='ui-li-aside'>completed</span></a></li>"
        else
          $(@el).append "<li><a href='#start-count?projectId=#{@project.id}&gateId=#{gate.gateId}'>Gate #{hour.gateGroupLetter}-#{gate.label}</a></li>"
    $(@el).listview('refresh')