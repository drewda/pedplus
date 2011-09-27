class App.Collections.Segments extends Backbone.Collection
  model: App.Models.Segment
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/segments"
  initialize: ->
    @bind "change", @change
  change: ->
    console.log "segments updated"
  geojson: ->
    geojson =
      type: 'FeatureCollection'
      features: _.compact @map (s) -> s.geojson()
  selected: ->
    @filter (s) -> s.selected
  selectAll: ->
    @each (s) -> s.select()
  selectNone: ->
    @each (s) -> s.deselect()