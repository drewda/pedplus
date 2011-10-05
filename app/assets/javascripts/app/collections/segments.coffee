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
  selectNone: ->
    _.each @selected(), (s) -> s.doDeselect()