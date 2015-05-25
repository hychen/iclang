require! mkdirp
require! rimraf
require! path
require! fs

{create-rpc-process, control-rpc-process} = ic.rpc!

describe 'Module RPC', ->
  describe 'functions', ->
    describe 'create-rpc-process()', -> ``it``
      beforeEach (done) ->
        <- mkdirp TEST_RUNTIME_DIR
        <- mkdirp TEST_RUNTIME_SOCKET_DIR
        done!
      afterEach (done) ->
        <- rimraf TEST_RUNTIME_DIR
        <- rimraf TEST_RUNTIME_SOCKET_DIR
        done!
      .. 'should create a rpc server', (done) ->
        comp = do
          friendlyName: 'A'
          inports: do
            in: do
              description: ''
          outports: do
            success: do
              description: 'done'
          fn: ->

        server, process <- create-rpc-process 'A', comp, {}
        server._socket?.should.be.ok
        server.close!
        process.stop!
        done!
    describe 'control-rpc-process()', ->
      var server, process
      beforeEach (done) ->
        <- mkdirp TEST_RUNTIME_DIR
        <- mkdirp TEST_RUNTIME_SOCKET_DIR
        comp = do
          friendlyName: 'A'
          inports: do
            in: do
              description: ''
          outports: do
            success: do
              description: 'done'
          fn: (inputs, exits) ->
            exits.success inputs.in + 1

        _server, _process <- create-rpc-process 'A', comp, {}
        server := _server
        process := _process
        done!
      afterEach (done) ->
        <- rimraf TEST_RUNTIME_DIR
        <- rimraf TEST_RUNTIME_SOCKET_DIR
        server.close!
        process.stop!
        done!
      describe 'ping()', (done) -> ``it``
        .. 'should repsponse `pong`', (done) ->
          err, res, _ <- control-rpc-process 'A','ping'
          res.should.be.eq 'pong'
          done!
      describe 'inquery(prop-name, query)', -> ``it``
        .. 'should return error message if the property is not supported.', (done) ->
          err, res, _ <- control-rpc-process 'A', 'inquery', 'utPortAddr', 'success'
          err.message.should.eq 'Inquery prop `utPortAddr` is not supported.'
          done!
      describe 'inquery(OutPortAddr, success)', -> ``it``
        .. 'should return ipc address of a process outport.', (done) ->
          err, res, _ <- control-rpc-process 'A', 'inquery', 'OutPortAddr', 'success'
          res.indexOf 'ipc://' .should.eq 0
          done!
        .. 'should raise error', (done) ->
          err, res, _ <- control-rpc-process 'A', 'inquery', 'OutPortAddr', 'notexists'
          err.message.should.eq "Port `notexists` not exists."
          done!
      describe 'connect()', -> ``it``
        .. 'should connect a inport to a outport on another process.', (done) ->
          comp = do
            friendlyName: 'B'
            inports: do
              in: do
                description: ''
            outports: do
              success: do
                description: 'done'
            fn: ->

          server, process <- create-rpc-process 'B', comp, {}
          err, res, _ <- control-rpc-process 'A', 'connect', 'in', 'B', 'success'
          expect err .to.be.not.ok
          done!
        .. 'should raise error if targe process is not running', (done) ->
          err, res, _ <- control-rpc-process 'A', 'connect', 'notexists', 'B', 'success'
          err.message.should.eq "target process B is not running"
          done!
        .. 'should raise error if the source port not exists.', (done) ->
          comp = do
            friendlyName: 'B'
            inports: do
              in: do
                description: ''
            outports: do
              success: do
                description: 'done'
            fn: ->

          server, process <- create-rpc-process 'B', comp, {}
          err, res, _ <- control-rpc-process 'A', 'connect', 'notexists', 'B', 'success'
          err.message.should.eq "source port `notexists` not exists"
          done!
        .. 'should raise error if the destination port not exists.', (done) ->
          comp = do
            friendlyName: 'B'
            inports: do
              in: do
                description: ''
            outports: do
              success: do
                description: 'done'
            fn: ->

          server, process <- create-rpc-process 'B', comp, {}
          err, res, _ <- control-rpc-process 'A', 'connect', 'in', 'B', 'notexists'
          err.message.should.eq "Port `notexists` not exists."
          done!
      describe 'fire()', -> ``it``
        .. 'should return result of component function.', (done) ->
          err, res, _ <- control-rpc-process 'A', 'fire', {in: 1}
          res.should.be.eq 2
          done!