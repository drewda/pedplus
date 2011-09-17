class App.Views.MapTab extends Backbone.View
  initialize: ->
    @render()
  render: ->
    $('#map-tab .button').button()
    $('#editing-mode').buttonset()
      .change (event) ->
        window.location.hash = "map/" + $('#editing-mode :checked').val()
    switch location.hash
      when '#map/view' then @editModeButton('view')
      when '#map/edit' then @editModeButton('edit')
      else @editModeButton('view')
  editModeButton: (newValue) ->
    $('#editing-mode input').each ->
       if $(this).val() == newValue
         $(this).attr('checked', true);
         $('#editing-mode').buttonset("refresh");