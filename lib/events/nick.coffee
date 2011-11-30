protocol = require('../protocol')
Event = require('./event').Event

class NickChangeEvent extends Event
  initialize: ->
    @nick = (@args[0] or @extended or '').trim()

    if @verify() and not @client.user.registered
      @client.user.nick = @nick
      @client.user.checkRegistered()
  
  type: ->
    'nick'
  
  verify: ->
    @nick and not @nick.match(protocol.validations.invalidNick)

exports.event = NickChangeEvent