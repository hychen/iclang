require! zmq
require! rimraf
require! mkdirp

{OutPort} = ic.port!

describe 'OutPort', ->
  beforeEach (done) ->
    mkdirp '/tmp/iclang/socket', done
  afterEach (done) ->
    rimraf '/tmp/iclang/socket', done
  describe 'has multiple ports that the direction is out.' -> ``it``
    .. 'can send JSON on particular port.', (done) ->
      ports = new OutPort <[out]>, runtime-dir: '/tmp/iclang'
      sock = zmq.socket 'pull'
      sock.connect ports.addr
      sock.on 'message', (message) -> 
        JSON.parse message.toString! .should.deep.eq {obj:1}
        ports.close!
        sock.close!
        done!
      ports.send {obj:1}
