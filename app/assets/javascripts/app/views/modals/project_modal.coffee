class App.Views.ProjectModal extends Backbone.View
  initialize: ->
    @render()
  id: 'project-modal'
  template: JST["app/templates/modals/project_modal"]
  render: ->
    $('body').append @template @options

    $('#project-modal').modal
      backdrop: "static"
      show: true

    # set the drop-down select to the project's existing value, as defined on the server
    $('#base-map-select').val masterRouter.projects.getCurrentProject().get 'base_map' 

    # binding for drop-down select
    $('#base-map-select').on "change", $.proxy @baseMapSelectChange, this

  # change the project's base map
  baseMapSelectChange: (event) ->
    baseMap = $('#base-map-select').val()
    masterRouter.projects.getCurrentProject().save
      base_map: baseMap
    ,
      success: ->
        $('#base-map-select').siblings('.help-inline').remove()
        $('#base-map-select').after '<span class="help-inline">Updated.</span>'
      error: ->
        $('#base-map-select').siblings('.help-inline').remove()
        $('#base-map-select').after '<span class="help-inline">Error updating.</span>'