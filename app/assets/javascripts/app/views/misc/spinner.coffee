class App.Views.Spinner extends Backbone.View
  initialize: ->
    $('#spinner').ajaxStart ->
      $(this).position
        of: $('body')
        my: 'center'
        at: 'center'
      $(this).fadeIn()
    $('#spinner').ajaxStop ->
      $(this).fadeOut()