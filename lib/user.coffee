protocol = require('./protocol')
UserRegisteredEvent = require('./events/user_registered').event

PING_WAIT = 30

class User
  constructor: (@client, @server) ->
    @registered = false
    @channels = []
    @setupPing()
  
  dispatch: (actor, verb, args, extended) ->
    line = protocol.combine(actor, verb, args, extended)
    @client.write "#{line}\r\n"
  
  disconnect: -> @client.end()
  
  disconnectCleanup: ->
    [@pingTimeout, @pingDisconnectTimeout].forEach (timeout) ->
      clearTimeout timeout if timeout?
  
  setupPing: ->
    if @pingTimeout?
      clearTimeout @pingTimeout
    if @pingDisconnectTimeout?
      clearTimeout @pingDisconnectTimeout
    
    @pingTimeout = setTimeout (=> @needPing()), PING_WAIT * 1000
  
  needPing: ->
    @dispatch null, 'ping', null, @server.hostname()
    @pingDisconnectTimeout = setTimeout (=> @pingDisconnect()), PING_WAIT * 2 * 1000
  
  pingDisconnect: ->
    # todo: ping timeout quit message
    @disconnect()

  touch: -> @setupPing()
  
  checkRegistered: ->
    if @nick and @ident and @realname
      event = new UserRegisteredEvent(@nick, @ident, @realname)
      event.client = @client
      @registered = true

      @server.fireEvent(event)
  
  hostmask: -> @client.remoteAddress # todo: hostname lookups, vhosts, oh my!
  toActor: -> "#{@nick}!#{@ident}@#{@hostmask()}"

  equals: (other) -> other and other.nick.toLowerCase() == @nick.toLowerCase()
  
exports.User = User