class App.Views.SegmentBottomBar extends Backbone.View
  initialize: ->
    @render()
    masterRouter.bind "route:mapView", @mapViewMode, this
    masterRouter.bind "route:mapEdit", @mapEditMode, this
  template: JST["app/templates/bottombar/segment"]
  render: ->
    switch location.hash
      when '#map/view' then @mapViewMode()
      when '#map/edit' then @mapEditMode()
  mapViewMode: ->
    $('#bottom-bar').empty()
    $('#bottom-bar').html @template segments.selected()[0].toJSON() 
  mapEditMode: ->
    $('#bottom-bar').empty()
    $('#bottom-bar').html @template segments.selected()[0].toJSON() 
    
    # draw button
    $('.object-actions .edit-actions').show().button()
    $('#segment-delete-button').button "option", "icons"
      primary: 'ui-icon-trash'
  
    # button logic    
    $('#segment-delete-button').bind "click", (event) ->
      new App.Views.DeleteSegmentDialog