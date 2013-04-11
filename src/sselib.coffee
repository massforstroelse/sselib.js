{EventEmitter} = require 'events'
util = require 'util'

typeCheck = (type, obj) ->
  cls = Object::toString.call(obj).slice(8, -1)
  obj isnt undefined and obj isnt null and cls is type

class SSE extends EventEmitter
  @defaultOptions =
    retry: 5*1000
    keepAlive: 15*1000

  @comment: (comment) ->
    ":#{comment}\n\n"

  @retry: (time) ->
    "retry: #{ time }\n"

  @event: (event) ->
    "event: #{ event }\n"

  @id: (id) ->
    "id: #{ id or (new Date()).getTime() }\n"

  @data: (data) ->
    unless typeCheck 'String', data
      data = JSON.stringify(data)
    "data: #{ data }\n\n"

  constructor: (@req, @res, @options = {}) ->
    unless @options
      @options = @constructor.defaultOptions
    else
      @options = util._extend(@options, @constructor.defaultOptions)
    @_writeHeaders() unless @res.headersSent
    @emit 'connected'
    @sendRetry options.retry
    ### XDomainRequest (MSIE8, MSIE9) ###
    @sendComment Array(2049).join ' '
    @_keepAlive() if @options.keepAlive
    ### Remy Sharp's Polyfill support. ###
    if @req.headers['x-requested-with'] is 'XMLHttpRequest'
      @res.xhr = null

    @lastEventId = @req.headers['last-event-id'] or null
    @emit 'reconnected' if @lastEventId

    @res.once 'close', =>
      clearInterval @intervalId if @intervalId
      @emit 'disconnected'

    callable = (message) =>
      @publish(message)
    callable.socket = @
    @emit 'ready'
    return callable

  sendComment: (comment) =>
    @res.write @constructor.comment(comment)

  sendRetry: (time) =>
    @res.write @constructor.retry(time)

  sendEvent: (event) =>
    @res.write @constructor.event(event)

  sendId: (id) =>
    @res.write @constructor.id(id)

  sendData: (data) =>
    @res.write @constructor.data(data)

  sendRaw: (data) =>
    @res.write data

  _processMessage: (obj) =>
    [id, event, data] =
    [@constructor.id(obj.id),
     @constructor.event(obj.event),
     @constructor.data(obj.data)]
    @res.write id + event + data

  _dispatchMessage: (message) =>
    if typeCheck 'Object', message
        @_processMessage(message)
    else if typeCheck 'String', message
        @sendData message
    else if typeCheck 'Array', message
        message.forEach (msg) -> @_dispatchMessage(msg)
    else
      throw new Error("Unparsable message. (#{ message })")

  _writeHeaders: ->
    @res.charset = 'utf-8'
    @res.statusCode = 200
    @res.setHeader "Content-Type", "text/event-stream"
    @res.setHeader "Cache-Control", "no-cache"
    @res.setHeader "Connection", "keep-alive"
    @res.setHeader "Transfer-Encoding", "identity"

  _keepAlive: () ->
    @intervalId = setInterval (=>
      @sendComment("KEEPALIVE #{ Date.now() }\n\n")
    ), @options.keepAlive

### Aliases ###
SSE::pub = SSE::_dispatchMessage
SSE::publish = SSE::_dispatchMessage
SSE::send = SSE::_dispatchMessage
module.exports = SSE

### Connect/Express middleware ###
module.exports.middleware = (options) ->
  ### Configuration, values in milliseconds ###
  options.retry = options?.retry or 3*1000
  options.keepAlive = options?.keepAlive or 15*1000
  return (req, res, next) ->
    if req.headers.accept is "text/event-stream"
      res.sse = new SSE req, res, options
    next()
