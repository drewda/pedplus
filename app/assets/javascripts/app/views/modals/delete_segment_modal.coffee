class App.Views.DeleteSegmentModal extends Backbone.View
  initialize: ->
    if masterRouter.hideDeleteSegmentConfirmation
      @deleteSegment(false)
    else
      @render()
  id: 'delete-segment-modal'
  template: JST["app/templates/modals/delete_segment_modal"]
  render: ->
    $('body').append @template @options
    $('#delete-segment-modal').modal
      backdrop: true
      show: true
    $('#delete-segment-button').on "click", $.proxy =>
      # if hide checkbox is checked, then we'll hide the modal for the rest of the session
      if $('#hide-delete-segment-confirmation').is(':checked')
        masterRouter.hideDeleteSegmentConfirmation = true
      @deleteSegment(true)
    , this
  deleteSegment: (segmentConfirmationDisplayed) ->
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
    
    if segmentConfirmationDisplayed
      $('#delete-geo-point-modal').modal('hide').remove()
      masterRouter.modals = []
    masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/map", true