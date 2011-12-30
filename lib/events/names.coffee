protocol = require('../protocol')
Event = require('./event').Event

class NamesEvent extends Event
  initialize: ->
    @channel = (@args[0] or @extended or '').trim()
  
  type: ->
    'names'
  
  verify: -> @channel and @server.findChannel(@channel)
  
  notVerified: ->
    if @channel
      @user.dispatch @server, protocol.errors.noSuchChannel, [@user.nick, @channel], 'No such channel'

exports.event = NamesEvent