// Generated by CoffeeScript 1.6.2
var Mock, SOCKET_INSTANCE_ALIASES, SOCKET_INSTANCE_OPTIONS_KEYS, SOCKET_INSTANCE_PROPERTIES_PRIVATE, SOCKET_INSTANCE_PROPERTIES_PUBLIC, app, connect, request, sendTestMessage, sselib, test, testMessage;

request = require('supertest');

connect = require('connect');

sselib = require('../sselib');

Mock = function() {
  var _this = this;

  this.req = {};
  this.req.headers = {};
  this.req.url = "http://example.com/";
  this.req.headers['last-event-id'] = "keyboard-cat";
  this.res = {};
  this.res.headers = {};
  this.res.setHeader = function(k, v) {
    return _this.res.headers[k] = v;
  };
  this.res.writeHead = function(code, reason, headers) {};
  this.res.once = function() {};
  this.res.write = function(chunk, encoding) {};
  return this;
};

testMessage = {
  id: 42,
  event: "hi",
  data: "yo"
};

SOCKET_INSTANCE_PROPERTIES_PUBLIC = ['sendComment', 'sendRetry', 'sendEvent', 'sendId', 'sendData', 'sendRaw', 'req', 'res', 'options'];

SOCKET_INSTANCE_PROPERTIES_PRIVATE = ['_processAndSendMessage', '_dispatchMessage', '_writeHeaders', '_keepAlive'];

SOCKET_INSTANCE_ALIASES = ['pub', 'publish', 'send'];

SOCKET_INSTANCE_OPTIONS_KEYS = ['keepAlive', 'retry', 'compatibility'];

describe('SSE', function() {
  describe('comment()', function() {
    it('should return a valid comment', function(done) {
      sselib.comment('cat').should.equal(': cat\n\n');
      return done();
    });
    return it('should return a valid comment to a optional callback', function(done) {
      return sselib.comment('cat', function(err, result) {
        result.should.equal(': cat\n\n');
        return done();
      });
    });
  });
  describe('retry()', function() {
    it('should return a valid retry instruction', function(done) {
      sselib.retry(3000).should.equal('retry: 3000\n');
      return done();
    });
    return it('should return a valid retry instruction to a optional callback', function(done) {
      sselib.retry(3000, function(err, result) {
        return result.should.equal('retry: 3000\n');
      });
      return done();
    });
  });
  describe('event()', function() {
    it('should return a valid event record', function(done) {
      sselib.event('cat').should.equal('event: cat\n');
      return done();
    });
    return it('should return a valid event record to a optional callback', function(done) {
      sselib.event('cat', function(err, result) {
        return result.should.equal('event: cat\n');
      });
      return done();
    });
  });
  describe('id()', function() {
    it('should return a valid id record', function(done) {
      sselib.id('cat').should.equal('id: cat\n');
      return done();
    });
    return it('should return a valid id record to a optional callback', function(done) {
      sselib.id('cat', function(err, result) {
        return result.should.equal('id: cat\n');
      });
      return done();
    });
  });
  describe('data()', function() {
    it('should return a valid data record', function(done) {
      sselib.data('cat').should.equal('data: cat\n\n');
      return done();
    });
    it('should return a valid data record to a optional callback', function(done) {
      sselib.data('cat', function(err, result) {
        return result.should.equal('data: cat\n\n');
      });
      return done();
    });
    it('should return a valid data record', function(done) {
      sselib.data('cat\nmouse').should.equal('data: cat\ndata: mouse\n\n');
      return done();
    });
    return it('should return a valid data record to a optional callback', function(done) {
      sselib.data('cat\nmouse', function(err, result) {
        return result.should.equal('data: cat\ndata: mouse\n\n');
      });
      return done();
    });
  });
  describe('message()', function() {
    it('should serialize a JSON to valid SSE', function(done) {
      sselib.message(testMessage).should.equal('id: 42\nevent: hi\ndata: yo\n\n');
      return done();
    });
    return it('should serialize a JSON to valid SSE to a optional callback', function(done) {
      sselib.message(testMessage, function(err, result) {
        return result.should.equal('id: 42\nevent: hi\ndata: yo\n\n');
      });
      return done();
    });
  });
  return describe('headers()', function() {
    it('should return a object containing valid SSE Headers', function(done) {
      sselib.headers().should.eql({
        'Content-Type': 'text/event-stream; charset=utf-8',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Transfer-Encoding': 'identity'
      });
      return done();
    });
    return it('should return a object containing valid SSE Headers to a optional callback', function(done) {
      sselib.headers(function(err, result) {
        return result.should.eql({
          'Content-Type': 'text/event-stream; charset=utf-8',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
          'Transfer-Encoding': 'identity'
        });
      });
      return done();
    });
  });
});

describe('Initialized SSE', function() {
  describe('The @options should be populated with default values', function() {
    var instance, mock;

    mock = new Mock();
    instance = new sselib(mock.req, mock.res);
    it('should have all the keys', function(done) {
      instance.options.should.have.keys(SOCKET_INSTANCE_OPTIONS_KEYS);
      return done();
    });
    it('should have the default value for keepAlive', function(done) {
      instance.options.should.have.property('keepAlive', 15 * 1000);
      return done();
    });
    it('should have the default value for retry', function(done) {
      instance.options.should.have.property('retry', 5 * 1000);
      return done();
    });
    return it('should have the default value for compatibility', function(done) {
      instance.options.should.have.property('compatibility', false);
      return done();
    });
  });
  describe('The options passed should take effect on the instance', function() {
    var instance, mock, options;

    options = {
      keepAlive: false,
      retry: 10 * 1000,
      compatibility: true
    };
    mock = new Mock();
    instance = new sselib(mock.req, mock.res, options);
    it('should have all the keys', function(done) {
      instance.options.should.have.keys(SOCKET_INSTANCE_OPTIONS_KEYS);
      return done();
    });
    it('should have the passed value for keepAlive', function(done) {
      instance.options.should.have.property('keepAlive', false);
      return done();
    });
    it('should have the passed value for retry', function(done) {
      instance.options.should.have.property('retry', 10 * 1000);
      return done();
    });
    return it('should have the passed value for compatibility', function(done) {
      instance.options.should.have.property('compatibility', true);
      return done();
    });
  });
  describe('The socket object should have all the public properties', function() {
    var instance, mock;

    mock = new Mock();
    instance = new sselib(mock.req, mock.res);
    return SOCKET_INSTANCE_PROPERTIES_PUBLIC.forEach(function(property) {
      return it("should have " + property, function(done) {
        instance.should.have.property(property);
        return done();
      });
    });
  });
  describe('The socket object should have all the private properties', function() {
    var instance, mock;

    mock = new Mock();
    instance = new sselib(mock.req, mock.res);
    return SOCKET_INSTANCE_PROPERTIES_PRIVATE.forEach(function(property) {
      return it("should have " + property, function(done) {
        instance.should.have.property(property);
        return done();
      });
    });
  });
  return describe('The socket object should have all the aliases', function() {
    var instance, mock;

    mock = new Mock();
    instance = new sselib(mock.req, mock.res);
    return SOCKET_INSTANCE_ALIASES.forEach(function(property) {
      return it("should have " + property, function(done) {
        instance.should.have.property(property);
        return done();
      });
    });
  });
});

test = function(app, signature) {
  return describe(signature, function() {
    return describe('when request "Accept" header text/event-stream', function() {
      return it('should respond and attach itself whenever seeing event-stream accept headers', function(done) {
        return request(app).get('/').set('Accept', 'text/event-stream').expect(200).expect('Content-Type', /text\/event-stream/).end(function(err, res) {
          if (err) {
            return done(err);
          }
          return done();
        });
      });
    });
  });
};

sendTestMessage = function(req, res, next) {
  var _this = this;

  res.sse(testMessage);
  setTimeout((function() {
    return res.end();
  }), 2 * 1000);
  return next();
};

app = connect();

app.use(sselib.middleware({
  keepAlive: false,
  retry: 10 * 1000
}));

app.use(sendTestMessage);

test(app, "As Middleware");

app = connect();

app.use(sselib.middleware({
  keepAlive: 1 * 1000,
  retry: 10 * 1000
}));

app.use(sendTestMessage);

test(app, "As Middleware with keep alive");
