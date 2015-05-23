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
      <- rimraf TEST_RUNTIME_DIR
      <- rimraf TEST_RUNTIME_SOCKET_DIR
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
    describe '#connect(src-port, dest-port-addr)', -> ``it``
      .. 'should raise error if the process is not running', (done) ->
        p = new Process 'A', do
              friendlyName: '...'
              fn: ->
        expect(-> p.connect 'out', '....').to.throw /process is not running/
        done!
      .. 'should raise error if src-port not exists', (done) ->
        p = new Process 'A', do
              friendlyName: '...'
              fn: ->
        p.start!
        expect(-> p.connect 'XXXX', '...').to.throw /port `XXXX` not exists/
        p.stop!
        done!
      .. 'should raise error if src-port not exists', (done) ->
        p = new Process 'A', do
              friendlyName: '...'
              outports: do
                out: do
                  destination: '...'
              fn: ->
        p.start!
        expect(-> p.connect 'out', '....').to.throw /port `out` is not a inport/
        p.stop!
        done!
    describe '#fire-token(token, exits)', -> ``it``
      .. 'should invoke component function within token', (done) ->
          p = new Process 'A', do
                friendlyName: '...'
                fn: (inputs, exits) ->
                  exits.ok inputs.str
          p.start!
          p.fire-token {+str}, do
            ok: ->
              it.should.be.ok
              done!
      .. 'should raise error if the process is not running', (done) ->
        p = new Process 'A', do
              friendlyName: '...'
              fn: ->
        expect(-> p.fire-token {a:1}).to.throw /the process is not running/
        done!
    describe '#_fire-stream()', -> ``it``
      .. 'should create exits callbacks used in component function.', (done) ->
        p = new Process 'A', do
              friendlyName: '...'
              outports:
                success: do
                  description: '...'
                error: do
                  description: '...'
              fn: (inputs, exits) ->
                exits.success?.should.be.ok
                exits.error?.should.be.ok
                p.stop!
                done!
        p.start!
        p._fire-stream!
      .. 'should make its component function be able to send data to specfied outports.', (done) ->
        p1 = new Process 'A', do
              friendlyName: '...'
              outports:
                success: do
                  description: '...'
                error: do
                  description: '...'
              fn: (inputs, exits) ->
                exits.success 'hello'
        p2 = new Process 'B',
              friendlyName: '...'
              inports:
                  in: do
                    description: '...'
              fn: (inputs, exits) ->
                exits.should.be.deep.eq {}
                inputs.in.should.eq 'hello'
                p1.stop!
                p2.stop!
                done!
        p1.start!
        p2.start!
        p2.connect 'in' p1.ports.success.addr
        p1._fire-stream!
