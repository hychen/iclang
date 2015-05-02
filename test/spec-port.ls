require! zmq
require! rimraf
require! mkdirp

{InPort, OutPort} = ic.port!

describe 'Port', ->
  beforeEach (done) ->
    mkdirp "#{TEST_RUNTIME_DIR}/socket", done
  afterEach (done) ->
    rimraf "#{TEST_RUNTIME_DIR}", done
  describe 'the direction can be Out.' -> ``it``
    .. 'should be able to send JSON.', (done) ->
      ports = new OutPort <[out]>
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
      outport = new OutPort <[out]>
      inport = new InPort null
      inport.connect outport
      inport.on 'data', ->
        it.should.be.deep.eq {obj:1} 
        outport.close!
        inport.close!
        done!
      outport.send {obj:1}      
