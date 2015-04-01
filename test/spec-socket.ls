should = require 'chai' .should!
expect = require 'chai' .expect

require! zmq
require! uuid

class Socket 

  (direction, port) ->
    @id = uuid.v4!
    @name = port.name
    @direction = direction
    @addr = null
    @sock = null
    @connected = false

    switch direction
      | 'in' => 
        @sock = zmq.socket 'pull'
      | 'out' => 
        @sock = zmq.socket 'push'
        @addr = "ipc:///tmp/iclang/#{@id}"
        @sock.bindSync @addr
      | _ => throw new Error 'invalid direction'

  is-connected: ->
    @connected == true

  connect: -> 
    @connected = true
    @sock.connect it

  disconnect: ->
    @connected = false

  send: (data) ->
    if @direction is 'out'
      @sock.send JSON.stringify data
    else 
      throw new Error 'try to send data on in socket.'

  on: (event-name, handler) ->
    @sock.on event-name, (msg) -> 
      data = JSON.parse msg
      throw new Error 
      handler 1

describe 'Socket', ->
  describe 'is directional.', -> ``it``
    .. 'should be `in` or `out` direction.', (done) ->
      new Socket 'in', {name: 'in'}
      new Socket 'out', {name: 'out'}
      expect(-> new Socket 'invalid', {name: 'out'}).throw /invalid direction/
      done!
  describe 'has a unique address.', -> ``it``
    .. 'could be a UUID.', (done) ->
      s1 = new Socket 'in', {name: 'in'}
      s2 = new Socket 'out', {name: 'out'}
      s1.id.should.not.eq s2.id 
      done!
  describe 'is communicatable iff it is connected with another soskcet', ->
    describe 'a in socket can recive a message sent from a out socket.', -> ``it``
      .. 'should be able send/recive JSON.', (done) ->
        insock = new Socket 'in', {name: 'in'}
        outsock = new Socket 'out', {name: 'out'}
        insock.connect outsock.addr
        #@FIXME: false asserstion does not work
        #@FIXME: on message callback cant throw error.
        insock.on 'message', -> it.should.be.not.deep.eq {obj:1}
        outsock.send {obj:1}
        false.should.be.ok
        done!
      .. 'should not be able send on in socket.', (done) ->
        insock = new Socket 'in', {name: 'in'}
        outsock = new Socket 'out', {name: 'out'}
        insock.connect outsock.addr
        insock.is-connected!.should.be.ok
        expect(-> insock.send 'hello').throw /try to send data on in socket/
        done!
