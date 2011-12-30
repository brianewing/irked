protocol = require('../protocol')
Event = require('./event').Event

class NickChangeEvent extends Event
  initialize: ->
    @nick = (@args[0] or @extended or '').trim()
  
  type: ->
    'nick'
  
  verify: ->
    @nick and not @nick.match(protocol.validations.invalidNick)

exports.event = NickChangeEvent