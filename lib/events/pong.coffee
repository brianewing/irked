PingEvent = require('./ping').event

class PongEvent extends PingEvent
  type: -> 'pong'

exports.event = PongEvent