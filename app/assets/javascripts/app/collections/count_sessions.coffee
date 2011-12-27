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
      # only include the CountSession's that are finished
      # otherwise this will refresh after NewCountSessionModal completes 
      # and creates a new CountSession that is in progress and incomplete
      if cs.get('stop')
        array.push [
          cs.id
          cs.get('segment_id')
          cs.get('start')
          cs.get('duration')
          cs.get('user_id')
          cs.get('counts_count')
          if !cs.get('selected') then false else cs.get('selected')
        ]
    return array