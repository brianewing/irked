protocol = require('../protocol')
Event = require('./event').Event

class JoinEvent extends Event
  initialize: ->
    @channel = (@args[0] or @extended or '').trim()
  
  type: -> 'join'
  
  verify: ->
    @channel and @channel[0] == '#' and not @channel.match(protocol.validations.invalidChannel)

exports.event = JoinEvent