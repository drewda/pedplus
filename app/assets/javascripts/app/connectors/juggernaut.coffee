class JuggernautConnector
  constructor: ->
    @juggernaut = new Juggernaut
  subscribeToOrganization: (organizationId) ->
    @juggernaut.subscribe "organization-#{organizationId}", @onData
  onData: (data) ->
    console.log "Got data: #{data}"
    if data.startsWith "modelJob-complete-"
      id = data.split('-').pop()
      masterRouter.modelTab.endPermeabilityAnalysis(id)
    else if data.startsWith "notice:-:"
      message = data.split(':-:').last
      $('#activity-report').append("<p>#{message}")
      