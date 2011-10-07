class App.Views.ModelTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    
    @projects.bind "reset", @render, this

    @topBar.render 'model'
    
    @render()
  template: JST["app/templates/top_bar/model_tab"]
  render: ->
    $('#tab-area').empty().html @template
    
    $('#run-permeability-analysis').bind "click", @beginPermeabilityAnalysis
    $('run-proximity-analysis').bind "click", @beginProximityAnalysis
    
  beginPermeabilityAnalysis: (event) ->
    modelJob = masterRouter.model_jobs.create
      project_id: masterRouter.projects.getCurrentProjectId()
      kind: 'permeability'
    ,
      success: ->
        $('#run-permeability-analysis').unbind()
        $('#run-permeability-analysis').addClass('disabled')
        $('#run-proximity-analysis').removeClass('primary').addClass('disabled')
        $('#spinner').fadeIn()
        # don't forget to do something when the ModelJob returns
  endPermeabilityAnalysis: ->
    $('#spinner').fadeOut()
    # $('#run-permeability-analysis').bind "click", @beginPermeabilityAnalysis 
    # are we sure we want to let them recompute?
    $('#run-permeability-analysis').removeClass('disabled')
    # what about the other button?
  
  beginProximityAnalysis: (event) ->
    # TODO
    