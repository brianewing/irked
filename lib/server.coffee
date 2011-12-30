_ = require('underscore')

version = require('./version')
protocol = require('./protocol')
net = require('net')

User = require('./user').User
Channel = require('./channel').Channel

class Server
  constructor: (config) ->
    @tcpServers = {}
    @clients = []
    @eventHandlers = {}
    @channels = []

    @config = config
    @addDefaultConfig()
    @addDefaultHandlers()
  
  version: -> version.full()

  initTcpServer: ->
    net.createServer (socket) =>
      @addClient(socket)
  
  addClient: (socket) ->
    @clients.push socket

    socket.user = new User(socket, @)

    socket.on 'data', (data) =>
      data.toString().split('\n').forEach (line) =>
        event = protocol.parseEvent(@, socket, line.trim())

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
      return if event.cancelled
      handler(event)
  
  addDefaultHandlers: ->
    @on 'ping', @onPing
    @on 'registered', @onRegistered
    @on 'nick', @onNick
    @on 'join', @onJoin
    @on 'message', @onMessage
  
  addDefaultConfig: ->
  
  hostname: -> @config.hostname

  welcomeMessage: ->
    "Welcome to #{@config.name}"
  
  hostMessage: ->
    "Your host is #{@hostname()} running #{@version()}"
  
  toActor: -> @hostname()

  findUser: (nickname) ->
    # todo: faster implementation
    
    (_.select @clients, (client) -> client.user.nick and client.user.nick.toLowerCase() == nickname.toLowerCase())[0]
  
  findChannel: (channel) ->
    # todo: faster implementation
    @channels[channel.toLowerCase()]
  
  makeChannel: (channel) ->
    @channels[channel.toLowerCase()] ||= new Channel(channel, @)

  onPing: (event) =>
    event.client.user.dispatch(@, 'pong', null, event.token)
  
  onRegistered: (event) =>
    user = event.client.user

    user.dispatch(@, protocol.reply.welcome, user.nick, @welcomeMessage())
    user.dispatch(@, protocol.reply.yourHost, user.nick, @hostMessage())
  
  onNick: (event) =>
    user = event.client.user

    if @findUser(event.nick)
      event.cancel()

      user.dispatch(@, protocol.errors.nameInUse, [user.nick, event.nick], 'Nickname is already being used')
    else
      user.dispatch(user, 'nick', null, event.nick) if user.registered
      user.nick = event.nick

      user.checkRegistered() unless user.registered
  
  onJoin: (event) =>
    user = event.client.user
    channel = @findChannel(event.channel)
    channel ||= @makeChannel(event.channel)

    channel.addUser(user)
  
  onMessage: (event) =>
    user = event.client.user
    channel = @findChannel(event.channel)
    
    if channel
      channel.dispatch user, 'privmsg', event.channel, event.message, (u) -> u.equals(user)
    else
      event.cancel()
      user.dispatch @, protocol.errors.noSuchChannel, event.channel, 'Cannot send message to channel'

exports.Server = Server
exports.createServer = (config) -> new Server(config)