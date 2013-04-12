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
    ": #{ comment }\n\n"

  @retry: (time) ->
    "retry: #{ time }\n"

  @event: (event) ->
    if event then "event: #{ event }\n" else ''

  @id: (id) ->
    "id: #{ if id then id else (new Date()).getTime() }\n"

  @data: (data) ->
    unless typeCheck 'String', data
      data = JSON.stringify(data)
    if data then "data: #{ data }\n\n" else ''

  @message: (obj) ->
    [@id(obj.id), @event(obj.event), @data(obj.data)].join('')

  @headers: ->
    'Content-Type': 'text/event-stream; charset=utf-8'
    'Cache-Control': 'no-cache'
    'Connection': 'keep-alive'
    'Transfer-Encoding': 'identity'

  constructor: (@req, @res, @options = {}) ->
    @options = util._extend(@constructor.defaultOptions, @options)
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
    @sendRaw @constructor.comment(comment)

  sendRetry: (time) =>
    @sendRaw @constructor.retry(time)

  sendEvent: (event) =>
    @sendRaw @constructor.event(event)

  sendId: (id) =>
    @sendRaw @constructor.id(id)

  sendData: (data) =>
    @sendRaw @constructor.data(data)

  sendRaw: (data) =>
    @res.write data

  _processAndSendMessage: (message) ->
    @sendRaw @constructor.message(message)

  _dispatchMessage: (message) =>
    if typeCheck 'Object', message
        @_processAndSendMessage(message)
    else if typeCheck 'String', message
        @sendData message
    else if typeCheck 'Array', message
        message.forEach (msg) -> @_dispatchMessage(msg)
    else
      throw new Error("Unparsable message. (#{ message })")

  _writeHeaders: ->
    @res.writeHead 200, 'OK', @constructor.headers()

  _keepAlive: () ->
    @intervalId = setInterval (=>
      @sendComment("keepalive #{ Date.now() }\n\n")
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
      res.sse = new SSE(req, res, options)
    next()
