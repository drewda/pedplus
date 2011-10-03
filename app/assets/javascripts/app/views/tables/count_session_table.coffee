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
    
    # fill the table
    @count_sessions.each (cs) =>
      if !cs.isNew()
        csr = new App.Views.CountSessionRow
          model: cs
        @countSessionRows.push csr
    , this
  remove: ->
    _.each @countSessionRows, (csr) =>
      csr.remove()
    $('#count-session-table-wrapper').remove()