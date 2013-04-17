request = require 'supertest'
connect = require 'connect'
express = require 'express'
sselib = require '../sselib'

# Utils
Mock = ->
  @req = {}
  @req.url = "http://example.com/" # fake the Url
  @req.headers = {}
  @req.headers['last-event-id'] = "keyboard-cat"
  @req.headers.accept = 'text/event-stream'
  @req.socket = {}
  @req.socket.address = =>
    return {port: 12346, family: 'IPv4', address: '127.0.0.1'}
  @res = {}
  @res.headers = {}
  @res.setHeader = (k, v) =>
    @res.headers[k] = v
  @res.writeHead = (code, reason, headers) =>

  @res.once = ->
  @res.end = ->
  @res.write = (chunk, encoding) ->
  this

testMessage =
  id: 42
  event: "hi"
  data: "yo"

# Properties
SOCKET_INSTANCE_PROPERTIES_PUBLIC =
  ['sendComment',
   'sendRetry',
   'sendEvent',
   'sendId',
   'sendData',
   'sendRaw',
   'req',
   'res',
   'options',
   'set',
   'get',
   'toString']

SOCKET_INSTANCE_PROPERTIES_PRIVATE =
  ['_processAndSendMessage',
   '_dispatchMessage',
   '_writeHeaders',
   '_keepAlive',
   '_compatibility']

SOCKET_INSTANCE_ALIASES =
  ['pub', 'publish', 'send']

SOCKET_INSTANCE_OPTIONS_KEYS =
  ['keepAlive', 'retry', 'compatibility']

# Let's begin testing!
describe 'SSE', -> # add @message

  describe 'comment()', ->
    it 'should return a valid comment', (done) ->
      sselib.comment('cat').should.equal ': cat\n\n'
      done()
    it 'should return a valid comment to a optional callback', (done) ->
      sselib.comment 'cat', (err, result) ->
        result.should.equal ': cat\n\n'
        done()
  
  describe 'retry()', ->
    it 'should return a valid retry instruction', (done) ->
      sselib.retry(3000).should.equal 'retry: 3000\n'
      done()
    it 'should return a valid retry instruction to a optional callback', (done) ->
      sselib.retry 3000, (err, result) ->
        result.should.equal 'retry: 3000\n'
      done()
  
  describe 'event()', ->
    it 'should return a valid event record', (done) ->
      sselib.event('cat').should.equal 'event: cat\n'
      done()
    it 'should return a valid event record to a optional callback', (done) ->
      sselib.event 'cat', (err, result) ->
        result.should.equal 'event: cat\n'
      done()
  
  describe 'id()', ->
    it 'should return a valid id record', (done) ->
      sselib.id('cat').should.equal 'id: cat\n'
      done()
    it 'should return a valid id record to a optional callback', (done) ->
      sselib.id 'cat', (err, result) ->
        result.should.equal 'id: cat\n'
      done()
  
  describe 'data()', ->
    it 'should return a valid data record', (done) ->
      sselib.data('cat').should.equal 'data: cat\n\n'
      done()
    it 'should return a valid data record to a optional callback', (done) ->
      sselib.data 'cat', (err, result) ->
        result.should.equal 'data: cat\n\n'
      done()

    it 'should return a valid data record', (done) ->
      sselib.data('cat\nmouse').should.equal 'data: cat\ndata: mouse\n\n'
      done()
    it 'should return a valid data record to a optional callback', (done) ->
      sselib.data 'cat\nmouse', (err, result) ->
        result.should.equal 'data: cat\ndata: mouse\n\n'
      done()

  describe 'message()', ->
    it 'should serialize a JSON to valid SSE', (done) ->
      sselib.message(testMessage).should.equal 'id: 42\nevent: hi\ndata: yo\n\n'
      done()
    it 'should serialize a JSON to valid SSE to a optional callback', (done) ->
      sselib.message testMessage, (err, result) ->
        result.should.equal 'id: 42\nevent: hi\ndata: yo\n\n'
      done()

  describe 'headers()', ->
    it 'should return a object containing valid SSE Headers', (done) ->
      sselib.headers().should.eql
        'Content-Type': 'text/event-stream; charset=utf-8'
        'Cache-Control': 'no-cache'
        'Connection': 'keep-alive'
        'Transfer-Encoding': 'identity'
      done()
    it 'should return a object containing valid SSE Headers to a optional callback', (done) ->
      sselib.headers (err, result) ->
        result.should.eql
          'Content-Type': 'text/event-stream; charset=utf-8'
          'Cache-Control': 'no-cache'
          'Connection': 'keep-alive'
          'Transfer-Encoding': 'identity'
      done()

describe 'Initialized SSE', ->

  describe 'The toString serialization should work', ->
      it 'should serialize properly', (done) ->
        mock = new Mock()
        instance = new sselib(mock.req, mock.res)
        instance.toString().should.equal "<SSE 127.0.0.1:12346 (IPv4)>"
        done()

  describe 'The @options should be populated with default values', ->
      mock = new Mock()
      instance = new sselib(mock.req, mock.res)
      it 'should have all the keys', (done) ->
        instance.options.should.have.keys(SOCKET_INSTANCE_OPTIONS_KEYS)
        done()

      it 'should have the default value for keepAlive', (done) ->
        instance.options.should.have.property('keepAlive', 15*1000)
        done()

      it 'should have the default value for retry', (done) ->
        instance.options.should.have.property('retry', 5*1000)
        done()
      it 'should have the default value for compatibility', (done) ->
        instance.options.should.have.property('compatibility', yes)
        done()

  describe 'The options passed should take effect on the instance', ->
      options =
        keepAlive: no
        retry: 10*1000
        compatibility: no
      mock = new Mock()
      instance = new sselib(mock.req, mock.res, options)
      it 'should have all the keys', (done) ->
        instance.options.should.have.keys(SOCKET_INSTANCE_OPTIONS_KEYS)
        done()

      it 'should have the passed value for keepAlive', (done) ->
        instance.options.should.have.property('keepAlive', no)
        done()

      it 'should have the passed value for retry', (done) ->
        instance.options.should.have.property('retry', 10*1000)
        done()
      it 'should have the passed value for compatibility', (done) ->
        instance.options.should.have.property('compatibility', no)
        done()

  describe 'The getter method should work', ->
      options =
        keepAlive: no
        retry: 10*1000
        compatibility: no
      mock = new Mock()
      instance = new sselib(mock.req, mock.res, options)
      it 'should be able to get keepAlive', (done) ->
        instance.get('keepAlive').should.eql no
        done()

      it 'should be able to get retry', (done) ->
        instance.get('retry').should.eql 10*1000
        done()

      it 'should be able to get compatibility', (done) ->
        instance.get('compatibility').should.eql no
        done()

  describe 'The setter method should work', ->
      mock = new Mock()
      instance = new sselib(mock.req, mock.res)
      it 'should be able to set keepAlive', (done) ->
        instance.set('keepAlive', 5000)
        instance.get('keepAlive').should.eql 5000
        done()

      it 'should be able to set retry', (done) ->
        instance.set('retry', 20000)
        instance.get('retry').should.eql 20*1000
        done()

      it 'should be able to set compatibility', (done) ->
        instance.set('compatibility', yes)
        instance.get('compatibility').should.eql yes
        done()


  describe 'The socket object should have all the public properties', ->
    mock = new Mock()
    instance = new sselib(mock.req, mock.res)
    SOCKET_INSTANCE_PROPERTIES_PUBLIC.forEach (property) ->
      it "should have #{ property }", (done) ->
        instance.should.have.property(property)
        done()
  
  describe 'The socket object should have all the private properties', ->
    mock = new Mock()
    instance = new sselib(mock.req, mock.res)
    SOCKET_INSTANCE_PROPERTIES_PRIVATE.forEach (property) ->
      it "should have #{ property }", (done) ->
        instance.should.have.property(property)
        done()
  
  describe 'The socket object should have all the aliases', ->
    mock = new Mock()
    instance = new sselib(mock.req, mock.res)
    SOCKET_INSTANCE_ALIASES.forEach (property) ->
      it "should have #{ property }", (done) ->
        instance.should.have.property(property)
        done()


testMiddleware = (connectApp, expressApp) ->
  describe "As middleware", ->

    describe 'As connect middleware', ->
      it 'should respond and attach itself whenever seeing event-stream accept headers', (done) ->
        request(connectApp).get('/').set('Accept', 'text/event-stream').expect(200).expect('Content-Type', /text\/event-stream/).end (err, res) ->
          return done(err) if err
          done()

    describe 'As express middleware', ->
      it 'should respond and attach itself whenever seeing event-stream accept headers', (done) ->
        request(expressApp).get('/').set('Accept', 'text/event-stream').expect(200).expect('Content-Type', /text\/event-stream/).end (err, res) ->
          return done(err) if err
          done()

    describe 'middleware API', ->
      app = sselib.middleware()
      mock = new Mock()

      it 'should provide the sse property to res', (done) ->
        app mock.req, mock.res, ->
          mock.res.should.have.property('sse')
          done()

      SOCKET_INSTANCE_PROPERTIES_PUBLIC.forEach (property) ->
        it "should provide the public property #{ property } under res.sse", (done) ->
          app mock.req, mock.res, ->
            mock.res.sse.should.have.property(property)
            done()

      SOCKET_INSTANCE_PROPERTIES_PRIVATE.forEach (property) ->
        it "should provide the private property #{ property } under res.sse", (done) ->
          app mock.req, mock.res, ->
            mock.res.sse.should.have.property(property)
            done()

      SOCKET_INSTANCE_ALIASES.forEach (property) ->
        it "should provide the alias #{ property } under res.sse", (done) ->
          app mock.req, mock.res, ->
            mock.res.sse.should.have.property(property)
            done()

sendTestMessage = (req, res, next) ->
  res.sse(testMessage)
  setTimeout (=> res.end()), 2*1000
  next()

connectApp = connect()
connectApp.use sselib.middleware()
expressApp = express()
expressApp.use sselib.middleware()
testMiddleware connectApp, expressApp
