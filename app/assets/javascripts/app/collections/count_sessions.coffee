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