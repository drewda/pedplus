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
    segments = _.compact _.flatten masterRouter.map_edits.pluck('segments')
    geo_points = _.compact _.flatten masterRouter.map_edits.pluck('geo_points')
    geo_point_on_segments = _.compact _.flatten masterRouter.map_edits.pluck('geo_point_on_segments')
    
    masterRouter.map_edits.reset()
    mapEdit = new App.Models.MapEdit
    masterRouter.map_edits.add mapEdit
    mapEdit.save
      project_id: masterRouter.projects.getCurrentProjectId()
      segments: segments
      geo_points: geo_points
      geo_point_on_segments: geo_point_on_segments
    ,
      success: (returnedMapEdit) ->
        masterRouter.map_edits.reset()
        $('#upload-map-edits-modal').modal('hide').remove()
        masterRouter.modals = []
        
        # update the project's version number
        masterRouter.projects.getCurrentProject().set
          version: returnedMapEdit.get('projectVersion')
        
        masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/map", true
        
        masterRouter.geo_points.reset()
        masterRouter.geo_point_on_segments.reset()
        masterRouter.segments.reset()
        masterRouter.count_sessions.reset()
        
        masterRouter.geo_points.fetch
          success: ->
            masterRouter.geo_point_on_segments.fetch
              success: -> 
                masterRouter.segments.fetch
                  success: ->
                    masterRouter.count_sessions.fetch()
      error: (model, error) ->
        alert "Error uploading edits to the server: #{error}"