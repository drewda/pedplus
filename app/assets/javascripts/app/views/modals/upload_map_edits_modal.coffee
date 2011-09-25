class App.Views.UploadMapEditsModal extends Backbone.View
  initialize: ->
    @render()
    @upload()
  id: 'upload-map-edits-modal'
  template: JST["app/templates/modals/upload_map_edits_modal"]
  render: ->
    $('body').prepend @template @options
    $('#upload-map-edits-modal').modal
      backdrop: true
      show: true
  upload: ->
    mapEdit = new App.Models.MapEdit
    masterRouter.map_edits.add mapEdit
    
    segments = masterRouter.segments.filter (s) => s.isNew() or s.hasChanged()
    geo_points = masterRouter.geo_points.filter (gp) => gp.isNew() or gp.hasChanged()
    geo_point_on_segments = masterRouter.geo_point_on_segments.filter (gpos) => gpos.isNew() or gpos.hasChanged()
    
    mapEdit.save
      segments: segments
      geo_points: geo_points
      geo_point_on_segments: geo_point_on_segments
    ,
      success: ->
        $('#upload-map-edits-modal').modal('hide').remove()
        masterRouter.modals = []