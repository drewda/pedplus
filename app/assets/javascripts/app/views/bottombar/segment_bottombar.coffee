class App.Views.SegmentBottomBar extends Backbone.View
  initialize: ->
    @render()
  template: JST["app/templates/bottombar/segment"]
  render: ->
    $('#bottom-bar').html @template segments.selected()[0].toJSON()
    $('#bottom-bar #segment-delete-button').button
      icon: 
        primary: 'ui-icon-trash'