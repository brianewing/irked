protocol = require('./protocol')

PING_WAIT = 30

class User
  constructor: (@client) ->
    @registered = false
    @setupPing()
  
  dispatch: (verb, args, extended) ->
    line = protocol.combine(verb, args, extended)
    @client.write "#{line}\r\n"
  
  disconnect: ->
    [@pingTimeout, @pingDisconnectTimeout].forEach (timeout) ->
      clearTimeout timeout if timeout?
    
    @client.end()
  
  setupPing: ->
    if @pingTimeout?
      clearTimeout @pingTimeout
    if @pingDisconnectTimeout?
      clearTimeout @pingDisconnectTimeout
    
    @pingTimeout = setTimeout (=> @needPing()), PING_WAIT * 1000
  
  needPing: ->
    @dispatch 'ping', null, 'irked'
    @pingDisconnectTimeout = setTimeout (=> @pingDisconnect()), PING_WAIT * 2 * 1000
  
  pingDisconnect: ->
    # todo: ping timeout quit message
    @disconnect()

  touch: ->
    @setupPing()

exports.User = User