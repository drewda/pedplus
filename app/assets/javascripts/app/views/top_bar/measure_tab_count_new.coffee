class App.Views.MeasureTabCountNew extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @renderData =
      project: @options.projects.getCurrentProject()

    # render top bar in modal style, without tab pills for navigation
    @topBar.render 'measure', false
    
    @render()
  template: JST["app/templates/top_bar/measure_tab_count_new"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template @renderData

    $('#start-count-session-now-button').bind "click", (event) =>
      countSession = new App.Models.CountSession
      masterRouter.count_sessions.add countSession
      countSession.save
        user_id: masterRouter.users.getCurrentUser().id
        project_id: masterRouter.projects.getCurrentProjectId()
        segment_id: masterRouter.segments.selected()[0].id
        duration_seconds: 10 * 60
      ,
        success: ->      
          countSession.select()
          
          masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count/count_session/#{countSession.id}/enter", true
        error: ->
          alert 'error saving count session to server'