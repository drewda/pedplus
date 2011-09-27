class App.Views.DeleteGeoPointModal extends Backbone.View
  initialize: ->
    @render()
  id: 'delete-geo-point-modal'
  template: JST["app/templates/modals/delete_geo_point_modal"]
  render: ->
    $('body').append @template @options
    $('#delete-geo-point-modal').modal
      backdrop: true
      show: true
    $('#delete-geo-point-button').bind "click", (event) =>
      geoPointToDelete = masterRouter.geo_points.selected()[0]
        
      segmentsToDelete = []
      geoPointOnSegmentsToDelete = []
      
      # delete Segment's (and their other GeoPointOnSegment's)
      _.each geoPointToDelete.getSegments(), (s) =>
        if s.getGeoPoints().length <= 2
          s.set
            markedForDelete: true
          segmentsToDelete.push s
          _.each s.getGeoPointOnSegments(), (gpos) =>
            gpos.set
              markedForDelete: true
            geoPointOnSegmentsToDelete.push gpos
        
      # delete GeoPoint
      geoPointToDelete.set
        markedForDelete: true
          
      # delete GeoPointOnSegment
      _.each geoPointToDelete.getGeoPointOnSegments(), (gpos) =>
        gpos.set
          markedForDelete: true
        geoPointOnSegmentsToDelete.push gpos
           
      mapEdit = new App.Models.MapEdit
      masterRouter.map_edits.add mapEdit
      mapEdit.set
        geo_points: [masterRouter.geo_points.selected()[0]]
        segments: segmentsToDelete
        geo_point_on_segments: geoPointOnSegmentsToDelete
      
      masterRouter.geo_points.selectNone()
      masterRouter.segments.selectNone()
      
      $('#delete-geo-point-modal').modal('hide').remove()
      masterRouter.modals = []
      masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/map", true