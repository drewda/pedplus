#= require_self
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

window.Smartphone =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  init: ->
    new Smartphone.Routers.Master

$ ->
  window.Smartphone.init()