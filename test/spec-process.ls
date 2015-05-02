require! mkdirp
require! rimraf

{Process, control-process} = ic.process!

describe 'Process', ->
  beforeEach (done) ->
    mkdirp './.ic/sock', done
  afterEach (done) ->
    rimraf './.ic/', done
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
