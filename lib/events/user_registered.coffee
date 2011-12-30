protocol = require('../protocol')
Event = require('./event').Event

class UserRegisteredEvent extends Event
  constructor: (@nick, @ident, @realname) ->
  type: -> 'registered'

exports.event = UserRegisteredEvent