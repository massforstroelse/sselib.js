{EventEmitter} = require 'events'

error = null
typeCheck = (type, obj) ->
  cls = Object::toString.call(obj).slice(8, -1)
  obj isnt undefined and obj isnt null and cls is type
extend = (origin, add) ->
  # Don't do anything if add isn't an object
  return origin  if not add or not typeCheck('Object', add)
  keys = Object.keys(add)
  for key in keys
    origin[key] = add[key]
  origin

class SSE extends EventEmitter
  @defaultOptions =
    retry: 5*1000
    keepAlive: 15*1000

  @comment: (comment, callback) ->
    serialized = ": #{ comment }\n\n"
    if not callback then serialized else callback(error, serialized)

  @retry: (time, callback) ->
    serialized = "retry: #{ time }\n"
    if not callback then serialized else callback(error, serialized)

  @event: (event, callback) ->
    serialized = if event then "event: #{ event }\n" else ''
    if not callback then serialized else callback(error, serialized)

  @id: (id, callback) ->
    if typeCheck 'Function', id
        callback = id
        id = null
    serialized = "id: #{ if id then id else (new Date()).getTime() }\n"
    if not callback then serialized else callback(error, serialized)

  @data: (data, callback) ->
    serialized = ''
    unless typeCheck('String', data) and data?
      data = JSON.stringify(data)
      serialized = if data then "data: #{ data }\n" else ''
    else
      data = data.split('\n')
      for piece in data
        serialized +=  "data: #{ piece }\n"
    serialized += '\n' if serialized
    if not callback then serialized else callback(error, serialized)

  @message: (obj, callback) ->
    serialized = [@id(obj.id), @event(obj.event), @data(obj.data)].join('')
    if not callback then serialized else callback(error, serialized)

  @headers: (callback) ->
    headerDict =
      'Content-Type': 'text/event-stream; charset=utf-8'
      'Cache-Control': 'no-cache'
      'Connection': 'keep-alive'
      'Transfer-Encoding': 'identity'
    if not callback then headerDict else callback(error, headerDict)

  constructor: (@req, @res, @options = {}) ->
    @options = extend(@constructor.defaultOptions, @options)
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
    @emit 'ready'

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

middleware = (req, res, options) ->
  callable = (message) -> @sse.socekt.publish(message)
  callable.socket = new SSE(req, res, options)
  return callable

### Connect/Express middleware ###
module.exports.middleware = (options) ->
  ### Configuration, values in milliseconds ###
  options.retry = options?.retry or 3*1000
  options.keepAlive = options?.keepAlive or 15*1000
  return (req, res, next) ->
    if req.headers.accept is "text/event-stream"
      res.sse = middleware(req, res, options)
    next()
