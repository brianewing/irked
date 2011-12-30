version = require('./version')
protocol = require('./protocol')
net = require('net')

User = require('./user').User

class Server
  constructor: (config) ->
    @tcpServers = {}
    @clients = []
    @eventHandlers = {}

    @config = config
    @addDefaultConfig()
    @addDefaultHandlers()
  
  version: -> version.full()

  initTcpServer: ->
    net.createServer (socket) =>
      @addClient(socket)
  
  addClient: (socket) ->
    @clients.push socket

    socket.user = new User(socket, @);

    socket.on 'data', (data) =>
      data.toString().split('\n').forEach (line) =>
        event = protocol.parseEvent(socket, line.trim())

        if event?
          @fireEvent(event)
          event.client.user.touch()
    
    socket.on 'end', =>
      socket.user.disconnectCleanup()
      @clients.splice @clients.indexOf(socket), 1
  
  listen: (port, host = "0.0.0.0") ->
    id = "#{host}:#{port}"

    @tcpServers[id] = @initTcpServer()
    @tcpServers[id].listen port, host
  
  on: (type, callback) ->
    @eventHandlers[type] ||= []
    @eventHandlers[type].push callback
  
  fireEvent: (event) ->
    type = event.type()
    return false if !@eventHandlers[type]?

    @eventHandlers[type].some (handler) ->
      handler(event)
  
  addDefaultHandlers: ->
    @on 'ping', @onPing
    @on 'registered', @onRegistered
  
  addDefaultConfig: ->
  
  hostname: -> @config.hostname

  welcomeMessage: ->
    "Welcome to #{@config.name}"
  
  hostMessage: ->
    "Your host is #{@hostname()} running #{@version()}"
  
  toActor: -> @hostname()

  onPing: (event) =>
    event.client.user.dispatch(@, 'pong', null, event.token)
  
  onRegistered: (event) =>
    user = event.client.user

    user.dispatch(@, protocol.reply.welcome, user.nick, @welcomeMessage())
    user.dispatch(@, protocol.reply.yourHost, user.nick, @hostMessage())

exports.Server = Server
exports.createServer = (config) -> new Server(config)