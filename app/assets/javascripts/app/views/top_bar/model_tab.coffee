class App.Views.ModelTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    
    @projects.bind "reset", @render, this

    @permeabilityAnalysisAgainstProjectVersion = null
    @proximityAnalysisAgainstProjectVersion = null
    
    @modelJob = null

    @topBar.render 'model'
    
    @render()
  template: JST["app/templates/top_bar/model_tab"]
  render: ->
    $('#tab-area').empty().html @template
    
    $('#permeability-analysis-button').bind "click", @permeabilityButton
    $('#proximity-analysis-button').bind "click", @beginProximityAnalysis
    
  permeabilityButton: (event) ->
    if @permeabilityAnalysisAgainstProjectVersion == masterRouter.projects.getCurrentProject().get('version') and masterRouter.map_edits.length == 0
      
      masterRouter.modelTab.showPermeabilityAnalysis()
    else
      masterRouter.modelTab.beginPermeabilityAnalysis()
    
  showPermeabilityAnalysis: ->
    masterRouter.map.modelMode "permeability"
    
  beginPermeabilityAnalysis: ->
    $('#permeability-analysis-button').addClass('primary').text 'Running Permeability Analysis'
    
    @modelJob = masterRouter.model_jobs.create
      project_id: masterRouter.projects.getCurrentProjectId()
      kind: 'permeability'
      project_version: masterRouter.projects.getCurrentProject().get('version')
    ,
      success: (model) ->
        $('#permeability-analysis-button').unbind()
        $('#permeability-analysis-button').addClass('disabled')
        $('#proximity-analysis-button').removeClass('primary').addClass('disabled')
        masterRouter.map.enableSegmentWorkingAnimation()
        @permeabilityPoll = setInterval 'masterRouter.modelTab.pollForPermeability()', 5000
      , this
      error: ->
        alert 'Error starting permeability analysis.'
  
  pollForPermeability: ->
    @modelJob.fetch
      success: (model) ->
        if model.get('output')
          clearInterval(@permeabilityPoll)
          masterRouter.modelTab.endPermeabilityAnalysis(model.id)
    
  endPermeabilityAnalysis: (modelJobId) ->
    masterRouter.model_jobs.fetch
      success: ->
        $('#permeability-analysis-button').bind "click", @permeabilityButton
        $('#permeability-analysis-button').removeClass('disabled').addClass('primary').text 'Permeability Analysis'
        masterRouter.map.disableSegmentWorkingAnimation()
        
        modelJob = masterRouter.model_jobs.get(modelJobId)
        
        masterRouter.modelTab.permeabilityAnalysisAgainstProjectVersion = modelJob.get('project_version')
        
        output = modelJob.get('output') # this is JSON
        outputJson = JSON.parse(output)
        
        _.each outputJson, (pv) =>
          masterRouter.segments.get(pv.segment_id).set
            permeabilityValue: pv.permeability
            permeabilityClass: pv.breakNum

        masterRouter.map.modelMode "permeability"
      error: ->
        alert 'Error fetching the results of the permeability analysis from the server.'
        
  beginProximityAnalysis: (event) ->
    # TODO
    