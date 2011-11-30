irked = require('./lib/server')

server = irked.createServer()
console.log "Running #{server.version()}"

[6667, 7000, 8000, 9000].forEach (port) ->
  server.listen port
  console.log "Listening on port #{port}"

server.on 'message', (event) ->
  console.log "New message in #{event.channel}: #{event.message}"