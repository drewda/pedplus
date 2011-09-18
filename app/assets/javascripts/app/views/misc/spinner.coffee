class App.Views.Spinner extends Backbone.View
  initialize: ->
    $('#spinner').ajaxStart ->
      $(this).fadeIn()
    $('#spinner').ajaxStop ->
      $(this).fadeOut()