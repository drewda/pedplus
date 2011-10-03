class App.Collections.Users extends Backbone.Collection
  model: App.Models.User
  url: '/api/users'
  getCurrentUser: ->
    @find (u) =>
      u.get 'is_current_user'