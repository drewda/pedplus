class App.Views.MeasureTabView extends Backbone.View
  initialize: ->
    @topBar = @options.topBar

    # if we're in the measureViewSelectedSegment route, we'll have a Segment ID
    if @options.segmentCid
      @segment = masterRouter.segments.getByCid(@options.segmentCid)
    else
      @segment = null
    # or if we're in the measureViewSelectedCountSession route, we'll have a CountSession ID
    if @options.countSessionId
      @countSession = masterRouter.count_sessions.get(@options.countSessionId)
    else
      @countSession = null

    @renderData =
      project: @options.projects.getCurrentProject()
      countSessions: masterRouter.count_sessions
      users: @options.users
      segment: @segment
      countSession: @countSession

    @topBar.render 'measure'

    # reload the segment layer in order to render the count colors
    masterRouter.segment_layer.layer.reload()
    
    @render()
  template: JST["app/templates/top_bar/measure_tab_view"]
  render: ->
    # render the template
    $('#tab-area').empty().html @template @renderData