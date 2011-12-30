MessageEvent = require('./events/message').event
PingEvent = require('./events/ping').event
PongEvent = require('./events/pong').event
NickChangeEvent = require('./events/nick').event
UserEvent = require('./events/user').event
JoinEvent = require('./events/join').event

exports.factory = (client, verb, args, extended) ->
  event = null

  mapping =
    "privmsg": MessageEvent
    "ping": PingEvent
    "pong": PongEvent
    "nick": NickChangeEvent
    "user": UserEvent
    "join": JoinEvent
  
  eventType = mapping[verb.toLowerCase()]
  event = new eventType(client, verb, args, extended) if eventType?
  
  if event? and event.verify()
    event
  else
    null