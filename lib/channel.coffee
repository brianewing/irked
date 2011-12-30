_ = require('underscore')
protocol = require('./protocol')

class Channel
  constructor: (@name, @server) ->
    @users = []
  
  addUser: (user) ->
    @users.push user
    @dispatch user, 'join', null, @name
  
  removeUser: (user) ->
    @users.splice @users.indexOf(user), 1
  
  hasUser: (user) ->
    _.include @users, user
  
  # dispatch something to *all* channel inhabitants
  dispatch: (actor, verb, args, extended, filter) ->
    @users.forEach (user) ->
      unless filter and filter(user)
        user.dispatch actor, verb, args, extended
  
exports.Channel = Channel