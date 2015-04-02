should = require 'chai' .should!
expect = require 'chai' .expect

# Change RUNTIME_SOCKETS_DIR before loading Socket class 
# for testing, so that spec-process test cases won't get wired 
# runtime environment.
TESTRUNTIME_SOCKETS_DIR = '/tmp/testiclang-sockets'

conf = require '../lib/config' .conf
conf.overrides do
  RUNTIME_SOCKETS_DIR: TESTRUNTIME_SOCKETS_DIR

require! mkdirp
require! rimraf
Socket = require '../lib/socket' .Socket

describe 'Socket', ->
  before ->
    <- mkdirp TESTRUNTIME_SOCKETS_DIR
  after ->
    <- rimraf TESTRUNTIME_SOCKETS_DIR
  describe 'is directional.', -> ``it``
    .. 'should be `in` or `out` direction.', (done) ->
      s = new Socket 'in', {name: 'in'}
      s.close!
      s = new Socket 'out', {name: 'out'}
      s.close!
      expect(-> new Socket 'invalid', {name: 'out'}).throw /invalid direction/
      done!
  describe 'has a unique address.', -> ``it``
    .. 'could be a UUID.', (done) ->
      s1 = new Socket 'in', {name: 'in'}
      s2 = new Socket 'out', {name: 'out'}
      s1.id.should.not.eq s2.id 
      s1.close!
      s2.close!
      done!
  describe 'is communicatable iff it is connected with another soskcet', ->
    describe 'a in socket can recive a message sent from a out socket.', -> ``it``
      .. 'should be able send/recive JSON.', (done) ->
        insock = new Socket 'in', {name: 'in'}
        outsock = new Socket 'out', {name: 'out'}
        insock.connect outsock.addr
        insock.on 'message', -> 
          it.should.be.deep.eq {obj:1}
        outsock.send {obj:1}
        #@FIXME: false asserstion does not work
        #@FIXME: on message callback cant throw error.
        insock.on 'message', -> 
          it.should.be.eq 1
        outsock.send {obj:1}
        insock.close!
        outsock.close!
        done!
      .. 'should not be able send on in socket.', (done) ->
        insock = new Socket 'in', {name: 'in'}
        outsock = new Socket 'out', {name: 'out'}
        insock.connect outsock.addr
        insock.is-connected!.should.be.ok
        expect(-> insock.send 'hello').throw /try to send data on in socket/
        insock.close!
        outsock.close!
        done!
