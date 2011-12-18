class App.Collections.CountSessions extends Backbone.Collection
  model: App.Models.CountSession
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/count_sessions"
  selected: ->
    @filter (cs) -> cs.get 'selected'
  selectAll: ->
    @each (cs) -> cs.select()
  selectNone: ->
    @each (cs) -> cs.deselect()
  arrayForDataTables: ->
    # columns: start, duration (minutes), total count
    array = []
    @each (cs) =>
      array.push [cs.get('start'), cs.get('duration'), cs.get('count_total')]
    return array