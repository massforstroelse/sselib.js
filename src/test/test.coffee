request = require 'supertest'
connect = require 'connect'
sselib = require '../sselib'

# Utils
Mock = ->
  @req = {}
  @req.headers = {}
  @req.url = "http://example.com/" # fake the Url
  @req.headers['last-event-id'] = "keyboard-cat"
  @res = {}
  @res.headers = {}
  @res.setHeader = (k, v) =>
    @res.headers[k] = v
  @res.once = ->
  @res.write = (chunk, encoding) ->
  this


SOCKET_INSTANCE_PROPERTIES_PUBLIC =
  ['sendComment',
   'sendRetry',
   'sendEvent',
   'sendId',
   'sendData',
   'sendRaw']

SOCKET_INSTANCE_PROPERTIES_PRIVATE =
  ['_processMessage',
   '_dispatchMessage',
   '_writeHeaders',
   '_keepAlive']

SOCKET_INSTANCE_ALIASES =
  ['pub', 'publish', 'send']

SOCKET_INSTANCE_OPTIONS_KEYS =
  ['keepAlive', 'retry']

describe 'SSE', ->
  describe 'comment()', ->
    it 'should return a valid comment', (done) ->
      sselib.comment('cat').should.equal ':cat\n\n'
      done()
  
  describe 'retry()', ->
    it 'should return a valid retry instruction', (done) ->
      sselib.retry(3000).should.equal 'retry: 3000\n'
      done()
  
  describe 'event()', ->
    it 'should return a valid event record', (done) ->
      sselib.event('cat').should.equal 'event: cat\n'
      done()
  
  describe 'id()', ->
    it 'should return a valid id record', (done) ->
      sselib.id('cat').should.equal 'id: cat\n'
      done()
  
  describe 'data()', ->
    it 'should return a valid data record', (done) ->
      sselib.data('cat').should.equal 'data: cat\n\n'
      done()

describe 'Initialized SSE', ->
  options =
    keepAlive: no
  mock = new Mock()
  instance = new sselib(mock.req, mock.res, options)

  describe 'The options passed should take effect on the instance', ->
      it 'should have all the keys', (done) ->
        instance.socket.options.should.have.keys(SOCKET_INSTANCE_OPTIONS_KEYS)
        done()

      it 'should have the passed value for keepAlive', (done) ->
        instance.socket.options.should.have.property('keepAlive', false)
        done()

      it 'should have the default value for retry', (done) ->
        instance.socket.options.should.have.property('retry', 5*1000)
        done()

  describe 'The socket object should have all the public properties', ->
    SOCKET_INSTANCE_PROPERTIES_PUBLIC.forEach (property) ->
      it 'should have #{ property }', (done) ->
        instance.socket.should.have.property(property)
        done()
  
  describe 'The socket object should have all the private properties', ->
    SOCKET_INSTANCE_PROPERTIES_PRIVATE.forEach (property) ->
      it 'should have #{ property }', (done) ->
        instance.socket.should.have.property(property)
        done()
  
  describe 'The socket object should have all the aliases', ->
    SOCKET_INSTANCE_ALIASES.forEach (property) ->
      it 'should have #{ property }', (done) ->
        instance.socket.should.have.property(property)
        done()

test = (app, signature) ->
  describe signature, ->
    describe 'when recv accept header text/event-stream', ->
      it 'should respond to event-stream accept headers', (done) ->
        request(app).get('/').set('Accept', 'text/event-stream').expect(200).expect('Content-Type', /text\/event-stream/).end (err, res) ->
          return done(err) if err
          done()

app = connect()
app.use sselib.middleware(keepAlive: no, retry: 10*1000)
test app, "sselib.middleware()"