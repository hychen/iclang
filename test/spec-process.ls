should = require 'chai' .should!
ic = require '../'
{Process, connect-port} = ic.process!
{init-runtime-env, clean-runtime-env} = ic.runtime!

fake-comp = do
  friendlyName: ''
  inports: {}
  outports: {}
  fn: ->

describe 'Process', ->
  beforeEach (done) ->
    err <- clean-runtime-env
    init-runtime-env done
  describe 'has a unique identifier.', -> ``it``
    .. 'should be UUID.', (done) ->
      p1 = new Process fake-comp
      p2 = new Process fake-comp
      p1.id.should.not.eq p2.id
      done!    
  describe 'is a instance of a component in the runtime.', -> ``it``
    .. 'should throw error if trying set a component on a process which is ready.', (done) ->
      p = new Process fake-comp
      (-> p.set-component fake-comp).should.throw /try to set a component on a process which is ready./
      done!
  describe 'should be running iff sockets is initializd.', -> ``it``
    .. 'may be running with 0 sockets.', (done) ->
      p = new Process fake-comp
      pid <- p.start
      pid.should.be.ok
      p.status!.should.eq 'running'
      <- p.stop
      done!
    .. 'may be running with sockets.', (done) ->
      comp = do
        friendlyName: ''
        inports: {in:{}}
        outports: {out:{}}
        fn: ->
      p = new Process comp
      pid <- p.start
      pid.should.be.ok
      p.ports.in.should.be.ok
      p.ports.out.should.be.ok
      <- p.stop
      done!
