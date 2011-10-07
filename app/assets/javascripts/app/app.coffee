#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers
#= require_tree ./connectors

window.App =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  init: ->
    new App.Routers.Master
    
    Backbone.history.start()

$ ->
  window.App.init()