request = require 'supertest'
connect = require 'connect'
sselib = require '../sselib'

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
  pub: '_dispatchMessage'
  publish: '_dispatchMessage'
  send: '_dispatchMessage'

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

test = (app, signature) ->
  describe signature, ->
    describe 'when recv accept header text/event-stream', ->
      it 'should respond to event-stream accept headers', (done) ->
        request(app).get('/').set('Accept', 'text/event-stream').expect(200).expect('Content-Type', /text\/event-stream/).end (err, res) ->
          return done(err) if err
          done()


  #describe "when Content-Length is too large", ->
  #  it "should respond with 413", (done) ->
  #    app.request().get("/").set("Accept", "text/event-stream").expect 413, done

app = connect()
app.use sselib.middleware(keepAlive: 3*1000, retry: 10*1000)
test app, "sselib.middleware()"