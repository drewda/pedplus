class App.Views.TopBar extends Backbone.View
  template: JST["app/templates/top_bar/top_bar"]
  render: (mode, showTabPills = true) ->
    $('#top-bar').empty().html @template
      currentProject: masterRouter.projects.getCurrentProject()
      currentUser: masterRouter.users.getCurrentUser()
      showTabPills: showTabPills

    # by default, we show the tab pills across the top and enable their actions
    # but if we send in showTabPills=false, the top bar will be displayed in a
    # modal style, without the ability to navigate away
    if showTabPills
      $("##{mode}-pill").addClass('active')

      # activate tooltips (which are used to mark unactivated PedPlus 
      # tabs and the map tab pill, when user doesn't have map permission)
      $("[rel=tooltip]").tooltip
        placement: 'right'

      $('#dashboard-link').click (event) =>
        bootbox.confirm "Do you want to exit and return to the dashboard?", (confirmed) =>
          window.location.href = "/" if confirmed

      $('#user-settings-link').click (event) =>
        userSettingsModal = new App.Views.UserSettingsModal
          user: masterRouter.users.getCurrentUser()

      $('#management-link').click (event) =>
        bootbox.confirm "Do you want to exit and proceed to the management interface?", (confirmed) =>
          window.location.href = "/manage" if confirmed

      $('#sign-out-link').click (event) =>
        bootbox.confirm "Do you want to exit and sign out?", (confirmed) =>
          window.location.href = "/users/sign_out" if confirmed