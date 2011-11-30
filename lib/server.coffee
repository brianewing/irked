version = require('./version')
protocol = require('./protocol')
net = require('net')

User = require('./user').User

class Server
  constructor: ->
    @tcpServers = {}
    @clients = []
    @eventHandlers = {}

    @addDefaultHandlers()
  
  version: -> version.full()

  initTcpServer: ->
    net.createServer (socket) =>
      @addClient(socket)
  
  addClient: (socket) ->
    @clients.push socket

    socket.user = new User(socket);

    socket.on 'data', (data) =>
      event = protocol.parseEvent(data)

      if event?
        event.client = socket
        @fireEvent(event.type(), event)

        event.client.user.touch()
    
    socket.on 'end', =>
      @clients.splice @clients.indexOf(socket), 1
  
  listen: (port, host = "0.0.0.0") ->
    id = "#{host}:#{port}"

    @tcpServers[id] = @initTcpServer()
    @tcpServers[id].listen port, host
  
  on: (type, callback) ->
    @eventHandlers[type] ||= []
    @eventHandlers[type].push callback
  
  fireEvent: (type, event) ->
    return false if !@eventHandlers[type]?

    @eventHandlers[type].some (handler) ->
      handler(event)
  
  addDefaultHandlers: ->
    @on 'ping', @onPing
  
  onPing: (event) ->
    event.client.user.dispatch('pong', null, event.token)

exports.createServer = ->
  new Server()