class App.Collections.GeoPoints extends Backbone.Collection
  model: App.Models.GeoPoint
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/geo_points"
  geojson: ->
    geojson =
      type: 'FeatureCollection'
      features: _.compact @map (gp) -> gp.geojson()
  selected: ->
    @filter (gp) -> gp.get 'selected'
  selectAll: ->
    @each (gp) -> gp.select()
  selectNone: ->
    @each (gp) -> gp.deselect()