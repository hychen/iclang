require! zmq
require! rimraf
require! mkdirp

{InPort, OutPort} = ic.port!

describe 'Port', ->
  beforeEach (done) ->
    mkdirp '/tmp/iclang/socket', done
  afterEach (done) ->
    rimraf '/tmp/iclang/socket', done
  describe 'the direction can be Out.' -> ``it``
    .. 'should be able to send JSON.', (done) ->
      ports = new OutPort <[out]>, runtime-dir: '/tmp/iclang'
      sock = zmq.socket 'pull'
      sock.connect ports.addr
      sock.on 'message', (message) -> 
        JSON.parse message.toString! .should.deep.eq {obj:1}
        ports.close!
        sock.close!
        done!
      ports.send {obj:1}
  describe 'the direction can be In.' -> ``it``
    .. 'should be able to receive JSON.', (done) ->
      outport = new OutPort <[out]>, runtime-dir: '/tmp/iclang'
      inport = new InPort null, runtime-dir: '/tmp/iclang'
      inport.connect outport
      inport.on 'data', ->
        it.should.be.deep.eq {obj:1} 
        outport.close!
        inport.close!
        done!
      outport.send {obj:1}      
