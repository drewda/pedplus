class App.Models.User extends Backbone.Model
  name: 'user'
  full_name: ->
    @get('first_name') + ' ' + @get('last_name')