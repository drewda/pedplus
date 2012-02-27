class Smartphone.Views.CountSessionListview extends Backbone.View
  initialize: ->
    count_sessions.bind "reset", @render, this
  render: ->
    $('#count-session-listview').empty()
    count_sessions.each (cs) =>
      $('#count-session-listview').append('another')