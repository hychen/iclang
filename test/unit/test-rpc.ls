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
