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
      _.each geoPointToDelete.getSegments(), (s) =>
        if s.getGeoPoints().length <= 2
          if s.isNew()
            masterRouter.segments.remove s
          else
            s.set
              markedForDelete: true
            segmentsToDelete.push s
          
      geoPointOnSegmentsToDelete = []
      _.each geoPointToDelete.getGeoPointOnSegments(), (gpos) =>
        if gpos.isNew()
          masterRouter.geo_point_on_segments.remove gpos
        else
          gpos.set
            markedForDelete: true
          geoPointOnSegmentsToDelete.push gpos
        
      if geoPointToDelete.isNew()
        masterRouter.geo_points.remove geoPointToDelete
      else
        geoPointToDelete.set
          markedForDelete: true
      
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