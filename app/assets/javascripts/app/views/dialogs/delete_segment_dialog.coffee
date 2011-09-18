class App.Views.DeleteSegmentDialog extends Backbone.View
  initialize: ->
    @render()
  render: ->
    $("#segment-delete-confirm").dialog
    			resizable: false
    			modal: true
    			buttons:
    				"Delete": ->
    				  geoPoint = segments.selected()[0]
    				  segments.selectNone()
    				  geoPoint.destroy
    				    success: (model, response) ->
    				      # uncheck the delete button
        					$('#segment-delete-button').attr("checked", false).button "refresh"
        					# close the delete confirmation dialog (and any other dialogs)
        					$(".ui-dialog-content").dialog "close"
        					masterRouter.fetchData() # reload
        					$('#bottom-bar').empty()
        				error: ->
        				  console.log "error destroying Segment"
    				Cancel: ->
    					$(this).dialog "close"
    					$('#segment-delete-button').attr("checked", false).button "refresh"