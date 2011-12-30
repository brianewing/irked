class Event
  constructor: (@server, @client, @verb, @args, @extended) ->
    @user = @client.user
    @initialize()
  
  initialize: ->
  
  type: -> 'generic'
  
  @registeredOnly = -> true
  
  verify: -> true
  
  notVerified: ->
  
  cancel: ->
    @cancelled = true

exports.Event = Event