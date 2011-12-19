class App.Views.CountSessionTable extends Backbone.View
  initialize: ->
    @countSessionRows = []
    
    @count_sessions = @options.count_sessions
    
    @count_sessions.bind "reset", @render, this
    
    @render()
  template: JST["app/templates/tables/count_session_table"]
  render: ->
    # render the table
    $('#count-session-table-wrapper').html @template
    $('#count-session-table').dataTable
      "sDom": "t<'#table-footer'<'#info'i><'#pagination'p>>"
      "bLengthChange": false
      "bFilter": false
      "sPaginationType": "bootstrap"
      "iDisplayLength": 4
      # "bScrollInfinite": true
      # "bScrollCollapse": true
      # "sScrollY": "100px"
      "aoColumns": [
        { "sTitle": "Start Time" , "sWidth": "33%", "fnRender": (oObj) => XDate(oObj.aData[0]).toString("d MMM yyyy h:mm tt") }
        { "sTitle": "Duration (minutes)" }
        { "sTitle": "Total Pedestrians Counted" }
      ]
      "aaData": @count_sessions.arrayForDataTables()
    
    # $('.count-session-row').bind "click", (event) =>
    #   id = event.currentTarget.id.split('-').pop()
    #   segmentId = masterRouter.count_sessions.get(id).get('segment_id')
    #   masterRouter.segments.get(segmentId).toggle()
  remove: ->
    _.each @countSessionRows, (csr) =>
      csr.remove()
    $('#count-session-table-wrapper').remove()