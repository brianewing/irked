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
  
  @registeredOnly = false
  
  type: -> 'user'
  verify: -> @ident and @mode and @realname and not @client.user.registered

exports.event = UserEvent