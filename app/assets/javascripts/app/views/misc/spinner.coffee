class App.Views.Spinner extends Backbone.View
  initialize: ->
    @enabled = true
    
    $('#spinner').ajaxStart ->
      if masterRouter.spinner.enabled
        # $(this).position
        #   of: $('body')
        #   my: 'center'
        #   at: 'center'
        $(this).fadeIn()
    $('#spinner').ajaxStop ->
      $(this).fadeOut()
      
  enable: ->
    @enabled = true
  disable: ->
    @enabled = false