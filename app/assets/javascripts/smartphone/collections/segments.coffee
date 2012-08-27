class Smartphone.Collections.Segments extends Backbone.Collection
  model: Smartphone.Models.Segment
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/segments"
  geojson: ->
    geojson =
      type: 'FeatureCollection'
      features: _.compact @map (s) -> s.geojson()