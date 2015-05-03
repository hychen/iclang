{ports-names, ports-length, port-addr} = ic.port!

ports = do
  in1:1
  in2: 2

describe 'Port functions', ->
  describe 'ports-names(ports)' -> ``it``
    .. 'should return each port name of ports.', (done) ->
      ports-names ports .should.deep.eq <[in1 in2]>
      done!
    .. 'should catch error if the input is not a object.', (done) ->
      expect(-> ports-names 1).to.throw /ports is not an object./
      expect(-> ports-names []).to.throw /ports is not an object./
      done!
  describe 'ports-length(ports)' -> ``it``
    .. 'should return count of ports.', (done) ->
      ports-length ports .should.eq 2
      done!
    .. 'should catch error if the input is not a object.', (done) ->
      expect(-> ports-length 1).to.throw /ports is not an object./
      expect(-> ports-length []).to.throw /ports is not an object./
      done!
  describe 'port-addr(id)', -> ``it``
    .. 'should return an ipc address.', (done) ->
      addr = port-addr 'pppppp' 
      addr.should.match /^ipc:\/\//
      addr.should.match /\.ic\/socket\/pppppp/
      done!
    .. 'should return an ipc address with configured runtime directory.', (done) ->
      process.env.RUNTIME_DIR = '/tmp'
      addr = port-addr 'pppppp' 
      addr.should.match /^ipc:\/\//
      addr.should.match /\/tmp\/socket\/pppppp/
      delete process.env.RUNTIME_DIR
      addr = port-addr 'pppppp' 
      addr.should.match /^ipc:\/\//
      addr.should.match /\.ic\/socket\/pppppp/
      done!
