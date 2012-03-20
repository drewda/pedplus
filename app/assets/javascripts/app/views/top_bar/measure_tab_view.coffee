class App.Views.MeasureTabView extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    @renderData =
      project: @options.projects.getCurrentProject()
      users: @options.users
      segmentId: @options.segmentId

    @topBar.render 'measure'

    # reload the segment layer in order to render the count colors
    masterRouter.segment_layer.layer.reload()
    
    @render()
  template: JST["app/templates/top_bar/measure_tab_view"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template @renderData