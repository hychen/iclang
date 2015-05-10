require! mkdirp
require! rimraf
require! path
require! fs

{Process} = ic.process!

describe 'Module Process', ->
  describe 'class Process', -> 
    beforeEach (done) ->  
      <- mkdirp TEST_RUNTIME_DIR 
      <- mkdirp TEST_RUNTIME_SOCKET_DIR
      done!
    afterEach (done) ->
#      <- rimraf TEST_RUNTIME_DIR
#      <- rimraf TEST_RUNTIME_SOCKET_DIR
      done!     
    describe '#constructor(name, component)', -> ``it`` 
      .. 'should raise error if the name is not valid.', (done) ->
        expect(-> new Process).to.throw 'process name is required'
        done!
      .. 'should raise error if the component is not valid.', (done) ->
        expect(-> new Process 'hello').to.throw 'component is required'
        done!
    describe '#start()', -> ``it``
      .. 'should create inports if the component has inports.', (done) ->
        p = new Process 'A', do
          friendlyName: '...'
          inports: do
            in: do
              description: '....'
          fn: ->
        p.start!
        p._status.should.eq 'running'
        p.ports.in?sock?_zmq?should.be.ok
        p.ports.in.sock.close!
        done!
      .. 'should create outports if the component has outports.', (done) ->
        p = new Process 'A', do
            friendlyName: '...'
            outports: do
              out: do
                description: '....'
            fn: ->
        p.start!
        p._status.should.eq 'running'
        p.ports.out?sock?_zmq?should.be.ok
        p.ports.out.sock.close!
        done!
    describe '#stop()', -> ``it``
      .. 'should close outports if the component has inports', (done) ->
        p = new Process 'A', do
            friendlyName: '...'
            outports: do
              out: do
                description: '....'
            fn: ->
        p.start!
        sockaddr = p.ports.out.addr.replace 'ipc://', ''
        p.stop!
        setTimeout (->
          fs.existsSync sockaddr .should.not.be.ok
          done!
        ), 1 
