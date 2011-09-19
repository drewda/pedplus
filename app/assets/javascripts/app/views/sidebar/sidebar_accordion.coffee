class App.Views.SidebarAccordion extends Backbone.View
  initialize: ->
    @render()
    
    new App.Views.UserTab
    new App.Views.ProjectTab
    new App.Views.MapTab
    new App.Views.MeasureTab
    new App.Views.ModifyTab
  render: ->
    accordionIndex = switch location.hash
      when '#user' then 0
      when '#project' then 1
      when '#map/view' then 2
      when '#map/edit' then 2
      when '#measure' then 3
      when '#modify' then 4
      else 1
    
    $('#accordion').accordion
      fillSpace: true
      active: accordionIndex
      change: (event, ui) ->
        masterRouter.trigger "changeMode", 
          $('a', ui.oldHeader).html().toLowerCase(), 
          $('a', ui.newHeader).html().toLowerCase()
        switch ui.options.active
          when 0 
            window.location.hash = "user"
          when 1
            window.location.hash = "project"
          when 2
            window.location.hash = "map/view"
          when 3
            window.location.hash = "measure"
          when 4
            window.location.hash = "modify"
    $(window).resize =>
      $('#accordion').accordion("resize")