{EventEmitter} = require 'events'
url = require 'url'

error = null

_utils = {} # utils ns
_utils.typeCheck = (type, obj) ->
  cls = Object::toString.call(obj).slice(8, -1)
  obj isnt undefined and obj isnt null and cls is type
_utils.extend = (origin, extension) ->
  # Don't do anything if extension isn't an object
  return origin if not extension or not _utils.typeCheck('Object', extension)
  for key, value of extension
    origin[key] = value unless origin[key]?
  origin

module.exports.utils = _utils

class SSE extends EventEmitter

  @defaultOptions =
    retry: 5*1000
    keepAlive: 15*1000
    compatibility: yes

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
    if _utils.typeCheck 'Function', id
        callback = id
        id = null
    serialized = "id: #{ if id then id else (new Date()).getTime() }\n"
    if not callback then serialized else callback(error, serialized)

  @data: (data, callback) ->
    serialized = ''
    unless _utils.typeCheck('String', data) and data?
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
    @options = _utils.extend(@options, @constructor.defaultOptions)
    @emit 'connected'
    @_writeHeaders()
    @_compatibility() if @options.compatibility
    @sendRetry(@options.retry) if @options.retry
    @_keepAlive() if @options.keepAlive
    if not @lastEventId
      @lastEventId = @req.headers['last-event-id'] or null
    @emit 'reconnected' if @lastEventId

    @res.once 'close', =>
      clearTimeout @_keepAliveTimer if @_keepAliveTimer
      @emit 'close'
    @emit 'ready'

  get: (option) =>
    if option of @options
      return @options[option]
    else
      throw new Error "Valid options are #{ (o for o of @options).join ',' }"

  set: (option, value) ->
    if option of @options
      @options[option] = value
      switch option
        when 'retry' then @sendRetry @options.retry
        when 'keepAlive'
          @once '_keepAlive', =>
            clearTimeout @_keepAliveTimer if @_keepAliveTimer
            @_keepAlive()
        when 'compatibility' then @_compatibility()
    else
      throw new Error "Valid options are #{ (o for o of @options).join ',' }"

  sendComment: (comment) =>
    @sendRaw @constructor.comment(comment)

  sendRetry: (time) =>
    @options.retry = time unless @options.retry is time
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
    @sendRaw "\n"

  _dispatchMessage: (message) =>
    if _utils.typeCheck 'Object', message
        @_processAndSendMessage(message)
    else if _utils.typeCheck 'String', message
        @sendData message

    else if _utils.typeCheck 'Array', message
        message.forEach (msg) -> @_dispatchMessage(msg)
    else
      throw new Error("Unparsable message. (#{ message })")

  _writeHeaders: ->
    @res.setHeader(header, value) for header, value of @constructor.headers()

  _keepAlive: ->
    schedule = =>
      setTimeout (=>
        @sendComment("keepalive #{ Date.now() }\n\n")
        @_keepAliveTimer = schedule()
        @emit '_keepAlive'
      ), @options.keepAlive
    @_keepAliveTimer = schedule()

  _compatibility: ->
    @res.setHeader 'Transfer-Encoding', 'chunked'
    ### XDomainRequest (MSIE8, MSIE9) ###
    @sendComment Array(2049).join ' '
    ### Remy Sharp's Polyfill support. ###
    if @req.headers['x-requested-with'] is 'XMLHttpRequest'
      @res.xhr = null

    if url.parse(@req.url, true).query.lastEventId
      @lastEventId = url.parse(@req.url, true).query.lastEventId


  toString: ->
    client = @req.socket.address()
    "<SSE #{ client.address }:#{ client.port } (#{ client.family })>"

### Aliases ###
SSE::pub = SSE::_dispatchMessage
SSE::publish = SSE::_dispatchMessage
SSE::send = SSE::_dispatchMessage

module.exports = SSE

### Connect/Express middleware ###
MIDDLEWARE_INSTANCE_PROPERTIES =
  ['sendComment',
   'sendRetry',
   'sendEvent',
   'sendId',
   'sendData',
   'sendRaw',
   'set',
   'get',
   'toString']

middleware = (req, res, options) ->
  callable = (message) -> @sse._socket.send(message)
  socket = new SSE(req, res, options)
  for property in MIDDLEWARE_INSTANCE_PROPERTIES
    callable[property] = socket[property]
  callable._socket = socket
  return callable

module.exports.middleware = (options) ->
  return (req, res, next) ->
    if req.headers.accept is "text/event-stream"
      res.sse = middleware(req, res, options)
    next() if next?
