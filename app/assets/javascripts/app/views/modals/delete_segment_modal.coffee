class App.Views.DeleteSegmentModal extends Backbone.View
  initialize: ->
    @render()
  id: 'delete-segment-modal'
  template: JST["app/templates/modals/delete_segment_modal"]
  render: ->
    $('body').append @template @options
    $('#delete-segment-modal').modal
      backdrop: true
      show: true
    $('#delete-segment-button').bind "click", (event) =>
      segmentToDelete = masterRouter.segments.selected()[0]
                
      geoPointOnSegmentsToDelete = []
      _.each segmentToDelete.getGeoPointOnSegments(), (gpos) =>
          gpos.set
            markedForDelete: true
          geoPointOnSegmentsToDelete.push gpos
        
      segmentToDelete.set
        markedForDelete: true
      $("#segment-layer #segment-line-#{segmentToDelete.cid}").remove()
    
      mapEdit = new App.Models.MapEdit
      masterRouter.map_edits.add mapEdit
      mapEdit.set
        geo_points: []
        segments: segmentToDelete
        geo_point_on_segments: geoPointOnSegmentsToDelete
      
      masterRouter.geo_points.selectNone()
      masterRouter.segments.selectNone()
      
      $('#delete-geo-point-modal').modal('hide').remove()
      masterRouter.modals = []
      masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/map", true