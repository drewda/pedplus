class App.Views.ManageCountPlansModal extends Backbone.View
  initialize: ->
    @render()
  id: 'manage-count-plans-modal'
  template: JST["app/templates/modals/manage_count_plans_modal"]
  render: ->
    $('body').append @template @options
    $('#manage-count-plans-modal').modal
      backdrop: "static"
      show: true

    $('#create-a-new-count-plan-button').bind "click", (event) =>
      $('#manage-count-plans-modal').modal 'hide'
      masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/plan/assistant", true

    $('#close-button').bind "click", (event) =>
      $('#manage-count-plans-modal').modal 'hide'