request = require 'supertest'
connect = require 'connect'
sselib = require '../sselib'

# Utils
mock = {}
mock.req = {}
mock.req.headers = {}
mock.req.url = "http://example.com/" # fake the Url
mock.req.headers['last-event-id'] = "keyboard-cat"
mock.res = {}
mock.res.headers = {}
mock.res.setHeader = (k, v) ->
  mock.res.headers[k] = v
mock.res.once = ->
mock.res.write = (chunk, encoding) ->


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
  ['pub',
   'publish',
   'send']

describe 'SSE', ->
  describe 'comment()', ->
    it 'should return a valid comment', ->
      sselib.comment('cat').should.equal ':cat\n\n'
  describe 'retry()', ->
    it 'should return a valid retry instruction', ->
      sselib.retry(3000).should.equal 'retry: 3000\n'
  describe 'event()', ->
    it 'should return a valid event record', ->
      sselib.event('cat').should.equal 'event: cat\n'
  describe 'id()', ->
    it 'should return a valid id record', ->
      sselib.id('cat').should.equal 'id: cat\n'
  describe 'data()', ->
    it 'should return a valid data record', ->
      sselib.data('cat').should.equal 'data: cat\n\n'

describe 'Initialized SSE', ->
  instance = new sselib(mock.req, mock.res, keepAlive: no)
  describe 'The socket object should have all the public properties', ->
    SOCKET_INSTANCE_PROPERTIES_PUBLIC.forEach (property) ->
      it 'should have #{ property }', ->
        instance.socket.should.have.property(property)
  describe 'The socket object should have all the private properties', ->
    SOCKET_INSTANCE_PROPERTIES_PRIVATE.forEach (property) ->
      it 'should have #{ property }', ->
        instance.socket.should.have.property(property)
  describe 'The socket object should have all the aliases', ->
    SOCKET_INSTANCE_ALIASES.forEach (property) ->
      it 'should have #{ property }', ->
        instance.socket.should.have.property(property)

test = (app, signature) ->
  describe signature, ->
    describe 'when recv accept header text/event-stream', ->
      it 'should respond to event-stream accept headers', (done) ->
        request(app).get('/').set('Accept', 'text/event-stream').expect(200).expect('Content-Type', /text\/event-stream/).end (err, res) ->
          return done(err) if err
          done()

app = connect()
app.use sselib.middleware(keepAlive: 3*1000, retry: 10*1000)
test app, "sselib.middleware()"