class App.Views.ModelTab extends Backbone.View
  initialize: ->
    @topBar = @options.topBar
    @projects = @options.projects
    @modelJobId = @options.modelJobId
    @mode = @options.mode
    
    @modelTabMode = ""
    @renderData = {}
    
    if @mode == "model"
      if masterRouter.model_jobs.getModelsForCurrentVersion("permeability").length > 0
        permeabilityModelJob = masterRouter.model_jobs.getModelsForCurrentVersion("permeability").pop()
        @modelTabMode = "modelExistingPermeability"
        @renderData =
          modelTabMode: @modelTabMode
          permeabilityModelJobId: permeabilityModelJob.id
          projectId: masterRouter.projects.getCurrentProjectId()
      else
        @modelTabMode = "modelNotYetPermeability"
        @renderData =
          modelTabMode: @modelTabMode
          projectId: masterRouter.projects.getCurrentProjectId()
    else if @mode == "modelPermeability"
      @modelJob = masterRouter.model_jobs.get(@modelJobId)
      
      @loadAndShowPermeability(@modelJob)
      
      @modelTabMode = "modelShowPermeability"
      @renderData = 
        modelTabMode: @modelTabMode
        projectId: masterRouter.projects.getCurrentProjectId()
    
    @projects.bind "reset", @render, this
    
    @modelJob = null

    @topBar.render 'model'
    
    @render()
  template: JST["app/templates/top_bar/model_tab"]
  render: ->
    $('#tab-area').empty().html @template @renderData
    
    $('#permeability-analysis-button').bind "click", @permeabilityButton
    # $('#proximity-analysis-button').bind "click", @beginProximityAnalysis
    
  permeabilityButton: (event) ->
    if masterRouter.modelTab.modelTabMode == "modelNotYetPermeability"
      masterRouter.modelTab.beginPermeabilityAnalysis()
    
  loadAndShowPermeability: (modelJob) ->
    output = modelJob.get('output') # this is JSON
    outputJson = JSON.parse(output)
    
    _.each outputJson, (pv) =>
      masterRouter.segments.get(pv.segment_id).set
        permeabilityValue: pv.permeability
        permeabilityClass: pv.breakNum

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
        masterRouter.spinner.disable()
        @permeabilityPoll = setInterval 'masterRouter.modelTab.pollForPermeability()', 5000
      , this
      error: ->
        alert 'Error starting permeability analysis.'
  
  pollForPermeability: ->
    @modelJob.fetch
      success: (model) ->
        if model.get('output')
          clearInterval(@permeabilityPoll)
          masterRouter.spinner.enable()
          masterRouter.modelTab.endPermeabilityAnalysis(model.id)
    
  endPermeabilityAnalysis: (modelJobId) ->
    masterRouter.model_jobs.fetch
      success: (modelJob) ->
        masterRouter.map.disableSegmentWorkingAnimation()
        masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/model/permeability/#{modelJobId}", true
      error: ->
        alert 'Error fetching the results of the permeability analysis from the server.'
    