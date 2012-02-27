class Smartphone.Views.ProjectPage extends Backbone.View
  el: '#page'
  initialize: ->
    Backbone.ModelBinding.bind(this);
    
    window.map = new Smartphone.Views.Map
    @countSessionListView = new Smartphone.Views.CountSessionListview