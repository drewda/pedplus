class Smartphone.Collections.Users extends Backbone.Collection
  model: Smartphone.Models.User
  url: '/api/users'
  getCurrentUser: ->
    @find (u) =>
      u.get 'is_current_user'