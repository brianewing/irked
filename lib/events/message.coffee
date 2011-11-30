events = require('../events')
protocol = require('../protocol')

Event = require('./event').Event

class MessageEvent extends Event
  initialize: ->
    target = @args[0]

    if target[0] == '#' and not target.match(protocol.validations.invalidChannel)
      @channel = target
    else if not target.match(protocol.validations.invalidNick)
      @user = target

    @message = @extended
  
  type: ->
    'message'
  
  verify: ->
    @message? and (@channel? or @user?)

exports.event = MessageEvent