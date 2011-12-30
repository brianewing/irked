class Event
  constructor: (@client, @verb, @args, @extended) ->
    @initialize()
  
  initialize: ->
  
  type: ->
    'generic'
  
  verify: ->
    true
  
  cancel: ->
    @cancelled = true

exports.Event = Event