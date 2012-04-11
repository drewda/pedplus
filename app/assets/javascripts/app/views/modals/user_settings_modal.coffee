class App.Views.UserSettingsModal extends Backbone.View
  initialize: ->
    @render()
  template: JST["app/templates/modals/user_settings_modal"]
  render: ->
    $('body').append @template @options
    $('#user-settings-modal').modal
      backdrop: "static"
      show: true
    $('#change-password-button').on "click touchstart", (event) =>
      if $('#new_password').val() and
         $('#new_password_confirmation').val() and
         $('#new_password').val() == $('#new_password_confirmation').val() and
         $('#new_password').val().length > 5
        $('#change-password-control-group').removeClass 'error'
        $('#change-password-button').button 'loading'
        user = masterRouter.users.getCurrentUser()
        user.save
          password: $('#new_password').val()
          password_confirmation: $('#new_password_confirmation').val()
        , 
          success: (model) =>
            $('#change-password-form').html '<p><span class="label success">Success</span> Your password has been changed.</p>'
          error: (model, response) =>
            $('#change-password-form').prepend '<p><span class="label important">Error</span> Your password could not be changed. Try again.</p>'
            $('#change-password-button').button 'reset'

      else 
        $('#change-password-control-group').addClass 'error'