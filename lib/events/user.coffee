protocol = require('../protocol')
Event = require('./event').Event

class UserEvent extends Event
  initialize: ->
    return if @args.length isnt 3

    @ident = @args[0]
    @mode = @args[1]
    @realname = @extended

    if @verify()
      @client.user.ident = @ident
      @client.user.realname = @realname
      @client.user.checkRegistered()
  
  type: ->
    'user'
  
  verify: ->
    return false if @client.user.registered

    @ident and @mode and @realname

exports.event = UserEvent