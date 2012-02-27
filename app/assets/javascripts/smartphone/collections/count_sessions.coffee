class Smartphone.Collections.CountSessions extends Backbone.Collection
  model: Smartphone.Models.CountSession
  url: ->
    "/api/projects/#{projects.getCurrentProjectId()}/count_sessions"
  selected: ->
    @filter (cs) -> cs.get 'selected'
  selectAll: ->
    @each (cs) -> cs.select()
  selectNone: ->
    @each (cs) -> cs.deselect()