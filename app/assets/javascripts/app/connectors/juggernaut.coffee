class JuggernautConnector
  constructor: ->
    @juggernaut = new Juggernaut
  subscribeToOrganization: (organizationId) ->
    @juggernaut.subscribe "organization-#{organizationId}", @onData
  onData: (data) ->
    console.log "Got data: #{data}"
    if data.startsWith "modelJob-complete-"
      id = data.split('-').pop
      masterRouter.model_jobs.fetch
        success: ->
          masterRouter.modelTab.endPermeabilityAnalysis()