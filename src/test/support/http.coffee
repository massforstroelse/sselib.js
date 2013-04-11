# https://raw.github.com/senchalabs/connect/master/test/support/http.js

###
Module dependencies.
###
request = (app) ->
  new Request(app)
Request = (app) ->
  self = this
  @data = []
  @header = {}
  @app = app
  unless @server
    @server = http.Server(app)
    @server.listen 0, ->
      self.addr = self.server.address()
      self.listening = true

EventEmitter = require("events").EventEmitter
methods = ["get", "post", "put", "delete", "head"]
connect = require("connect")
http = require("http")
module.exports = request
connect.proto.request = ->
  request this


###
Inherit from `EventEmitter.prototype`.
###
Request::__proto__ = EventEmitter::
methods.forEach (method) ->
  Request::[method] = (path) ->
    @request method, path

Request::set = (field, val) ->
  @header[field] = val
  this

Request::write = (data) ->
  @data.push data
  this

Request::request = (method, path) ->
  @method = method
  @path = path
  this

Request::expect = (body, fn) ->
  args = arguments_
  @end (res) ->
    switch args.length
      when 3
        res.headers.should.have.property body.toLowerCase(), args[1]
        args[2]()
      else
        if "number" is typeof body
          res.statusCode.should.equal body
        else
          res.body.should.equal body
        fn()


Request::end = (fn) ->
  self = this
  if @listening
    req = http.request(
      method: @method
      port: @addr.port
      host: @addr.address
      path: @path
      headers: @header
    )
    @data.forEach (chunk) ->
      req.write chunk

    req.on "response", (res) ->
      buf = ""
      res.setEncoding "utf8"
      res.on "data", (chunk) ->
        buf += chunk

      res.on "end", ->
        res.body = buf
        fn res


    req.end()
  else
    @server.on "listening", ->
      self.end fn

  this