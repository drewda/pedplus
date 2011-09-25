class App.Collections.GeoPointOnSegments extends Backbone.Collection
  model: App.Models.GeoPointOnSegment
  url: ->
    "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/geo_point_on_segments"