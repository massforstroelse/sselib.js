sselib = require "../sselib"

describe 'SSE', ->
  describe 'comment()', ->
    it 'should return a valid comment', ->
      sselib.SSE.comment("cat").should.equal ":cat\n\n"
  describe 'retry()', ->
    it 'should return a valid retry instruction', ->
      sselib.SSE.retry(3000).should.equal ":retry 3000\n"
  describe 'event()', ->
    it 'should return a valid event record', ->
      sselib.SSE.event("cat").should.equal "event: cat\n"
  describe 'id()', ->
    it 'should return a valid id record', ->
      sselib.SSE.id("cat").should.equal "id: cat\n"
  describe 'data()', ->
    it 'should return a valid data record', ->
      sselib.SSE.data("cat").should.equal "data: cat\n\n"