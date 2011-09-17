class App.Views.DeleteGeoPointDialog extends Backbone.View
  initialize: ->
    @render()
  render: ->
    $("#geo-point-delete-confirm").dialog
    			resizable: false
    			modal: true
    			buttons:
    				"Delete": ->
    				  geoPoint = geo_points.selected()[0]
    				  geo_points.selectNone()
    				  geoPoint.destroy
    				    success: (model, response) ->
    				      # uncheck the delete button
        					$('#geo-point-delete-button').attr("checked", false).button "refresh"
        					# close the delete confirmation dialog (and any other dialogs)
        					$(".ui-dialog-content").dialog "close"
        					masterRouter.fetchData() # reload
        					$('#bottom-bar').empty()
        				error: ->
        				  console.log "error destroying GeoPoint"
    				Cancel: ->
    					$(this).dialog "close"
    					$('#geo-point-delete-button').attr("checked", false).button "refresh"