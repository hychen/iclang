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
          fn: ->

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