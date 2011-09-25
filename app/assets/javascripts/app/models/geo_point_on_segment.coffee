class App.Models.GeoPointOnSegment extends Backbone.Model
  name: 'geo_point_on_segment'
  getGeoPoint: ->
    if local = masterRouter.geo_points.getByCid(@get 'geo_point_cid')
      return local
    else if server = masterRouter.geo_points.get(@get 'geo_point_id')
      return server
  getSegment: ->
    if local = masterRouter.segments.getByCid(@get 'segment_cid')
      return local
    else if server = masterRouter.segments.get(@get 'segment_id')
      return server