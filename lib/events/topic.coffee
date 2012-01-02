protocol = require('../protocol')
Event = require('./event').Event

class TopicEvent extends Event
  initialize: ->
    @channel = (@args[0] or '').trim()
    @newTopic = (@extended or '').trim()
  
  type: -> 'topic'
  
  verify: -> @channel and @server.findChannel(@channel)
  
  notVerified: ->
    if @channel
      @user.dispatch @server, protocol.errors.noSuchChannel, [@user.nick, @channel], 'No such channel'

exports.event = TopicEvent