class Event
  constructor: (@client, @verb, @args, @extended) ->
    @initialize()
  
  initialize: ->
  
  type: ->
    'generic'
  
  verify: ->
    true

exports.Event = Event