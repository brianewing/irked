events = require('../events')
Event = require('./event').Event

class PingEvent extends Event
  constructor: (verb, args, extended) ->
    super verb, args, extended

    @token = extended
  
  type: ->
    'ping'

exports.event = PingEvent