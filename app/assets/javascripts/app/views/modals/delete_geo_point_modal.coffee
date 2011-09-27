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
            masterRouter.map_edits.each (me) =>
              segmentsMinusThisOne = _.reject me.get('segments'), (sInMe) =>
                sInMe.cid == s.cid
              me.set
                segments: segmentsMinusThisOne
          else
            s.set
              markedForDelete: true
            segmentsToDelete.push s
          
      geoPointOnSegmentsToDelete = []
      _.each geoPointToDelete.getGeoPointOnSegments(), (gpos) =>
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
        
      if geoPointToDelete.isNew()
        masterRouter.geo_points.remove geoPointToDelete
        masterRouter.map_edits.each (me) =>
          gpsMinusThisOne = _.reject me.get('geo_points'), (gpInMe) =>
            gpInMe.cid == geoPointToDelete.cid
          me.set
            geo_points: gpsMinusThisOne
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