class App.Collections.Segments extends Backbone.Collection
  model: App.Models.Segment
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/segments"
  geojson: ->
    geojson =
      type: 'FeatureCollection'
      features: _.compact @map (s) -> s.geojson()
  selected: ->
    @filter (s) -> s.get 'selected'
  selectAll: ->
    @each (s) -> s.select()
  selectNone: ->
    @each (s) -> s.deselect()