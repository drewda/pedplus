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
        if gpos.isNew()
          masterRouter.geo_point_on_segments.remove gpos
          masterRouter.map_edits.each (me) =>
            gposMinusThisOne = _.reject me.get('geo_point_on_segments'), (gposInMe) =>
              gposInMe.cid == gpos.cid
            me.set
              geo_point_on_segments: gposMinusThisOne
        else
          gpos.set
            markedForDelete: true
          geoPointOnSegmentsToDelete.push gpos
        
      if segmentToDelete.isNew()
        masterRouter.segments.remove segmentToDelete
        masterRouter.map_edits.each (me) =>
          segmentsMinusThisOne = _.reject me.get('segments'), (sInMe) =>
            sInMe.cid == segmentToDelete.cid
          me.set
            segments: segmentsMinusThisOne
      else
        segmentToDelete.set
          markedForDelete: true
      
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