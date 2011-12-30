_ = require('underscore')
protocol = require('./protocol')

class Channel
  constructor: (@name, @server) ->
    @users = []
  
  addUser: (user) ->
    return if @hasUser(user)
    @users.push user
    @dispatch user, 'join', null, @name
    @sendNames user
  
  removeUser: (user) ->
    @users.splice @users.indexOf(user), 1
  
  hasUser: (user) ->
    _.include @users, user
  
  # dispatch something to *all* channel inhabitants
  dispatch: (actor, verb, args, extended, filter) ->
    @users.forEach (user) ->
      unless filter and filter(user)
        user.dispatch actor, verb, args, extended
  
  sendNames: (user) ->
    # check the rfc when implementing private/secret channels, as this changes
    nicks = _.pluck @users, 'nick'
    while nicks.length
      names = nicks.splice(0, 25)
      user.dispatch @server, protocol.reply.nameReply, [user.nick, '=', @name], names.join(' ')
    
    user.dispatch @server, protocol.reply.endNames, [user.nick, @name], 'End of NAMES list'
  
exports.Channel = Channel