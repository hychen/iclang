require! mkdirp
require! rimraf

{Process, WorkerProcess, control-process} = ic.process!

mock-component = (name, inports, outports, fn) ->
  tr = ->
    o = {}
    for p in it
      o[p] = do
        description: "port description."
    return o
  do
    friendlyName: name
    inports: tr inports
    outports: tr outports
    fn: fn


describe 'Process', ->
  beforeEach (done) ->
    mkdirp "#{TEST_RUNTIME_DIR}/socket", done
  afterEach (done) ->
    rimraf "#{TEST_RUNTIME_DIR}", done
  describe 'should be able controlled via RPC.', -> ``it``
    .. '#status()', (done) ->
      hello = new Process 'hello'
      hello.start!
      err, res, more <- control-process 'hello', 'status'
      expect err .to.eq undefined
      res.should.be.eq 'ready'
      hello.stop!
      done!
    .. '#run()', (done) ->
      p = new Process 'ready-process'
      p.start!
      err, res, more <- control-process 'ready-process', 'run'
      err, res, more <- control-process 'ready-process', 'status'
      expect err .to.not.be.ok
      res.should.be.eq 'running'
      p.stop!
      done!
    .. '#pause()', (done) ->
      p = new Process 'running-process'
      p.start!
      err, res, more <- control-process 'running-process', 'run'
      err, res, more <- control-process 'running-process', 'pause'
      err, res, more <- control-process 'running-process', 'status'
      expect err .to.eq undefined
      res.should.be.eq 'suspend'
      p.stop!
      done!
    .. '#connect()', (done) ->
      p1 = new Process 'process1'
      p2 = new Process 'process2'
      p1.start!
      p2.start!
      err, res, more <- control-process 'process1', 'run'
      err, res, more <- control-process 'process2', 'run'
      err, res, more <- control-process 'process1', 'connect', 'port1', 'process2:port1'
      expect err .to.eq undefined
      p1.stop!
      p2.stop!
      done!

describe 'WorkerProcess', ->
  beforeEach (done) ->
    mkdirp "#{TEST_RUNTIME_DIR}/socket", done
  afterEach (done) ->
    rimraf "#{TEST_RUNTIME_DIR}", done
  describe 'is a instance of a component.', -> ``it``
    .. 'should have 0-infinit ports.', (done) ->
      p = new WorkerProcess 'Fake', mock-component 'Fake', <[in]>, <[out]>, ->
      p.ports.should.deep.eq {}
      p.start!
      p.ports.in.name.should.eq 'in'
      p.ports.out.name.should.eq 'out'
      p.ports.out.addr.should.ok
      p.stop!
      done!
  describe 'can be controlled by RPC.', -> ``it``
    .. '#fire()', (done) ->
      fn = (inputs, exits) -> 
        exits.success {out:inputs.in + 1}
      comp = mock-component 'Fake', <[in]>, <[out]>, fn
      p = new WorkerProcess 'Fake', comp
      p.ports.should.deep.eq {}
      p.start!
      err, res, more <- control-process 'Fake', 'run'
      err, res, more <- control-process 'Fake', 'fire', {in:1}
      res.should.be.deep.eq {out:2}
      p.stop!
      done!
