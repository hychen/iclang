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
        ), 0.0001 
    describe '#inquery(prop-name, query)', (done) -> ``it``
      .. 'should raise error if prop name is not supported.', (done) ->
        p = new Process 'A', do
              friendlyName: '...'
              fn: ->
        expect(-> p.inquery 'XXXX').to.throw /Inquery prop `XXXX` is not supported/
        done!
      describe '#inquery(\'OutPortAddr\', query)', -> ``it``
        .. 'should return ipc address if asking the address of a outport', (done) ->
          p = new Process 'A', do
              friendlyName: '...'
              outports: do
                out: do
                  description: '....'
              fn: ->
          p.start!
          p.inquery 'OutPortAddr', 'out' .should.eq p.ports.out.addr
          done!
        .. 'should riase error if asking the address of a inport', (done) ->
          p = new Process 'A', do
              friendlyName: '...'
              fn: ->
          p.start!
          expect(-> p.inquery 'OutPortAddr', 'in').to.throw 'Port `in` not exists.'
          done!        
        .. 'should riase error if asking the address of a inport', (done) ->
          p = new Process 'A', do
              friendlyName: '...'
              inports: do
                in: do
                  description: '....'
              fn: ->
          p.start!
          expect(-> p.inquery 'OutPortAddr', 'in').to.throw 'Port `in` is not a outport.'
          done!
