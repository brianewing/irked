class Event
  constructor: (@verb, @args, @extended) ->
  
  type: ->
    'generic'
  
  verify: ->
    true

exports.Event = Event