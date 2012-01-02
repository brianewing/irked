MessageEvent = require('./events/message').event
PingEvent = require('./events/ping').event
PongEvent = require('./events/pong').event
NickChangeEvent = require('./events/nick').event
UserEvent = require('./events/user').event
JoinEvent = require('./events/join').event
NamesEvent = require('./events/names').event
TopicEvent = require('./events/topic').event

exports.factory = (server, client, verb, args, extended) ->
  event = null

  mapping =
    "privmsg": MessageEvent
    "ping": PingEvent
    "pong": PongEvent
    "nick": NickChangeEvent
    "user": UserEvent
    "join": JoinEvent
    "names": NamesEvent
    "who": NamesEvent # todo: implement WHO properly
    "topic": TopicEvent
  
  eventType = mapping[verb.toLowerCase()]

  if eventType? and (not eventType.registeredOnly or client.user.registered)
    event = new eventType(server, client, verb, args, extended) if eventType?
    if event.verify()
      event
    else
      event.notVerified()
      null
  else
    return null