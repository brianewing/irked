events = require('../events')
Event = require('./event').Event

class PingEvent extends Event
  initialize: ->
    @token = @extended
  
  type: -> 'ping'

exports.event = PingEvent