sselib = require "../sselib"

describe 'SSE', ->
  describe 'comment()', ->
    it 'should return a valid comment', ->
      sselib.comment("cat").should.equal ":cat\n\n"
  describe 'retry()', ->
    it 'should return a valid retry instruction', ->
      sselib.retry(3000).should.equal "retry: 3000\n"
  describe 'event()', ->
    it 'should return a valid event record', ->
      sselib.event("cat").should.equal "event: cat\n"
  describe 'id()', ->
    it 'should return a valid id record', ->
      sselib.id("cat").should.equal "id: cat\n"
  describe 'data()', ->
    it 'should return a valid data record', ->
      sselib.data("cat").should.equal "data: cat\n\n"