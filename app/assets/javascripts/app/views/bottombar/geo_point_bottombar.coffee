class App.Views.GeoPointBottomBar extends Backbone.View
  initialize: ->
    @render()
    masterRouter.bind "route:mapView", @mapViewMode, this
    masterRouter.bind "route:mapEdit", @mapEditMode, this
  template: JST["app/templates/bottombar/geo_point"]
  render: ->
    switch location.hash
      when '#map/view' then @mapViewMode()
      when '#map/edit' then @mapEditMode()
  mapViewMode: ->
    $('#bottom-bar').empty()
    $('#bottom-bar').html @template geo_points.selected()[0].toJSON() 
  mapEditMode: ->
    $('#bottom-bar').empty()
    $('#bottom-bar').html @template geo_points.selected()[0].toJSON() 
    
    # draw buttons
    $('.object-actions .edit-actions').show().buttonset()
    $('#geo-point-connect-button').button "option", "icons"
        primary: 'ui-icon-transferthick-e-w'
    $('#geo-point-move-button').button "option", "icons"
      primary: 'ui-icon-arrow-4-diag'
    $('#geo-point-delete-button').button "option", "icons"
      primary: 'ui-icon-trash'
  
    # button logic    
    $('#geo-point-connect-button').bind "click", (event) ->
      if $('#geo-point-connect-button').attr("checked") == "checked"
        masterRouter.navigate("map/edit/geo_point/connect/#{geo_points.selected()[0].id}", true)
        
      else
        masterRouter.navigate("map/edit", true)
    
    $('#geo-point-move-button').bind "click", (event) ->
      masterRouter.navigate("map/edit/geo_point/move/#{geo_points.selected()[0].id}", true)
      
    $('#geo-point-delete-button').bind "click", (event) ->
      new App.Views.DeleteGeoPointDialog