protocol = require('../protocol')
Event = require('./event').Event

class NickChangeEvent extends Event
  initialize: ->
    @nick = (@args[0] or @extended or '').trim()
  
  @registeredOnly = false
  
  type: ->
    'nick'
  
  verify: ->
    @nick and not @nick.match(protocol.validations.invalidNick)
  
  notVerified: ->
    @user.dispatch @server, protocol.errors.badNick, [@user.nick, @nick], 'Invalid nickname'

exports.event = NickChangeEvent