class App.Views.CountSessionTable extends Backbone.View
  initialize: ->
    @table = null
    
    @count_sessions = @options.count_sessions
    
    # @count_sessions.bind "reset", @render, this
    
    @render()
  render: ->
    # reset table filtering functions
    $.fn.dataTableExt.afnFiltering = []

    # if in measureSelectedSegment mode, filter just for that segment's CountSession's
    if masterRouter.currentRouteName.startsWith "measureSelectedSegment"
      selectedSegmentCid = masterRouter.currentRouteName.split(':').pop()
      selectedSegmentId = masterRouter.segments.getByCid(selectedSegmentCid).id
      $.fn.dataTableExt.afnFiltering.push (oSettings, aData, iDataIndex) =>
        if aData[1] == selectedSegmentId
          return true
        else 
          return false
      
    # render the table
    @table = $('#count-session-table').dataTable
      "sDom": "Tt<'#table-footer'<'#info'i><'#pagination'p>>"
      # "bDestroy": true
      "bLengthChange": false
      "bFilter": true
      "sPaginationType": "bootstrap"
      "iDisplayLength": 4
      # "bScrollInfinite": true
      # "bScrollCollapse": true
      # "sScrollY": "100px"
      "bSort": true
      "aoColumns": [
        { "bVisible": false } # this is CountSession.id
        { "bVisible": false} # this is CountSession.segment_id
        { "sTitle": "Start Time", "sType": "date", "fnRender": (oObj) => XDate(oObj.aData[2]).toString("d MMM yyyy h:mm tt") }
        { "sTitle": "Duration (minutes)" , "fnRender": (oObj) => oObj.aData[3] }
        { "sTitle": "Taken By", "fnRender": (oObj) => masterRouter.users.get(oObj.aData[4]).full_name() }
        { "sTitle": "Total Pedestrians Counted" }
        { "bVisible": false, "sType": "string" } # this is CountSession.selected
      ]
      "aaSorting": [[6, 'desc']]
      "aaData": @count_sessions.arrayForDataTables()
      "fnRowCallback": (nRow, aData, iDisplayIndex) =>
        countSessionId = aData[0]
        segmentId = aData[1]
        $(nRow).attr "id", "count-session-table-row-#{countSessionId}"
        if masterRouter.currentRouteName == "measureSelectedCountSession:#{countSessionId}"
          $(nRow).addClass "selected"
        else if masterRouter.currentRouteName.startsWith "measureSelectedSegment"
          if segmentId == masterRouter.segments.getByCid(masterRouter.currentRouteName.split(':').pop()).id
            $(nRow).addClass "selected"
        return nRow
      "oTableTools":
        "aButtons": []
        "sRowSelect": "single"
        "sSelectedClass": "selected"
        "fnRowSelected": (node) =>
          id = node.id.split('-').pop()
          masterRouter.count_sessions.get(id).select()
          # masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count_session/#{id}", true
        "fnRowDeselected": (node) =>
          masterRouter.count_sessions.selectNone()
          masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/view", true
          
  remove: ->
    $('#count-session-table-wrapper').remove()

  redraw: ->
    @table.fnDraw()