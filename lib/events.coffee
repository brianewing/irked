MessageEvent = require('./events/message').event
PingEvent = require('./events/ping').event
PongEvent = require('./events/pong').event

exports.factory = (verb, args, extended) ->
  event = null

  switch verb.toLowerCase()
    when "privmsg"
      event = new MessageEvent(verb, args, extended)
    when "ping"
      event = new PingEvent(verb, args, extended)
    when "pong"
      event = new PongEvent(verb, args, extended)
  
  if event? and event.verify()
    event
  else
    null