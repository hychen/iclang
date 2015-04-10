should = require 'chai' .should!

{Process, connect-port} = require '../lib/process'
{init-runtime-env, clean-runtime-env} = require '../lib/runtime'

fake-comp = do
  inports: []
  outports: []

describe 'Process', ->
  beforeEach (done) ->
    err <- clean-runtime-env
    init-runtime-env done
  describe 'has a unique identifier.', -> ``it``
    .. 'should be UUID.', (done) ->
      p1 = new Process 
      p2 = new Process
      p1.id.should.not.eq p2.id
      done!    
  describe 'is a instance of a component in the runtime.', -> ``it``
    .. 'should not be ready if the component isnt given.', (done) ->
      p = new Process 
      p.is-ready!.should.not.ok
      done!
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
        inports: [{name:'in'}]
        outports: [{name:'out'}]
      p = new Process comp
      pid <- p.start
      pid.should.be.ok
      p.ports.in.should.be.ok
      p.ports.out.should.be.ok
      <- p.stop
      done!
