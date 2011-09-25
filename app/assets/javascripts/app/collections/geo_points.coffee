class App.Collections.GeoPoints extends Backbone.Collection
  model: App.Models.GeoPoint
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/geo_points"
  initialize: ->
    @bind "change", @change
  change: ->
    console.log 'geo_points updated'
  geojson: ->
    geojson =
      type: 'FeatureCollection'
      features: @map (gp) -> gp.geojson()
  selected: ->
    @filter (gp) -> gp.selected
  selectAll: ->
    @each (gp) -> gp.select()
  selectNone: ->
    @each (gp) -> gp.deselect()