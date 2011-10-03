class App.Views.CountSessionRow extends Backbone.View
  initialize: ->
    @render()
    @model.bind "change", @update, this
  template: JST["app/templates/tables/count_session_row"]
  render: ->
    $("#count-session-table tbody").append @template @model.toJSON()
  update: ->
    $("#count-session-row-#{@model.id}").html @template @model.toJSON()
  remove: ->
    @model.unbind()
    $("#count-session-row-#{@model.id}").remove()
    