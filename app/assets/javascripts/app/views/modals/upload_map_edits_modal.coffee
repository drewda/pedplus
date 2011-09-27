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
    
    segments = _.compact _.flatten masterRouter.map_edits.pluck('segments')
    geo_points = _.compact _.flatten masterRouter.map_edits.pluck('geo_points')
    geo_point_on_segments = _.compact _.flatten masterRouter.map_edits.pluck('geo_point_on_segments')
    
    masterRouter.map_edits.add mapEdit
    mapEdit.save
      segments: segments
      geo_points: geo_points
      geo_point_on_segments: geo_point_on_segments
    ,
      success: ->
        masterRouter.geo_points.fetch
          success: ->
            masterRouter.geo_point_on_segments.fetch
              success: -> 
                masterRouter.segments.fetch()
        masterRouter.map_edits.reset()
        $('#upload-map-edits-modal').modal('hide').remove()
        masterRouter.modals = []
        masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/map", true
      error: (model, error) ->
        alert error