class App.Views.SidebarAccordion extends Backbone.View
  initialize: ->
    @render()
    
    new App.Views.UserTab
    new App.Views.ProjectTab
    new App.Views.MapTab
    new App.Views.MeasureTab
    new App.Views.ModifyTab
  render: ->
    $('#accordion').accordion
      fillSpace: true
      active: 1
      change: (event, ui) ->
        # oldMode = $('a', ui.oldHeader).html()
        # newMode = $('a', ui.newHeader).html()
        # console.log oldMode + " --> " + newMode
        switch ui.options.active
          when 0 
            window.location.hash = "user"
          when 1
            window.location.hash = "project"
          when 2
            window.location.hash = "map"
          when 3
            window.location.hash = "measure"
          when 4
            window.location.hash = "modify"