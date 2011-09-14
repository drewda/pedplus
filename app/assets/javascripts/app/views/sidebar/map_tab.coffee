class App.Views.MapTab extends Backbone.View
  initialize: ->
    @render()
  render: ->
    $('#map-tab .button').button()
    $('#editing-mode').buttonset()
      .change (event) ->
        console.log "editing mode --> " + $('#editing-mode :checked').val()