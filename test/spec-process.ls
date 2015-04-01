should = require 'chai' .should!

{Process, init-runtime-env, clean-runtime-env} = require '../lib/process'

fake-comp = do
  inports: []
  outports: []

describe 'Process', ->
  beforeEach ->
    err <- clean-runtime-env
  describe 'has a unique identifier.', -> ``it``
    .. 'should be UUID.', (done) ->
      p1 = new Process 
      p2 = new Process
      p1.id.should.not.eq p2.id
      done!    
  describe 'is a instance of a component in the runtime.', -> ``it``
    .. 'should not be ready if the component isnt given.', (done) ->
      <- init-runtime-env
      p = new Process 
      p.is-ready!.should.not.ok
      done!
  describe 'should be ready iff required environment is prepared.', -> ``it``
    .. 'should have a given component and runtime directory.', (done) ->
      p = new Process fake-comp
      p.is-ready!.should.be.not.ok
      <- init-runtime-env
      p = new Process fake-comp
      p.is-ready!.should.be.ok
      done!
    .. 'should throw error if trying set a component on a process which is ready.', (done) ->
      <- init-runtime-env
      p = new Process fake-comp
      (-> p.set-component fake-comp).should.throw /try to set a component on a process which is ready./
      done!
  describe 'should be running iff sockets is initializd.', -> ``it``
    .. 'may be running with 0 sockets.', (done) ->
      <- init-runtime-env
      p = new Process fake-comp
      pid <- p.start
      pid.should.be.ok
      p.status!.should.eq 'running'
      <- p.stop
      done!
    .. 'may be running with sockets.', (done) ->
      <- init-runtime-env
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

describe 'Process Firing', ->
  describe 'is executing the function of the component with recievied arguments on in sockets.', -> ``it``
    describe 'the component function without arguments.', ->
      .. 'should send the returned values of the function to outports.', (done) ->
        <- init-runtime-env 
        p1 = new Process do
          inports: []
          fn: ->
            {out:'hello'}
          outports: [{name:'out'}]
        p2 = new Process do          
          inports: [{name: 'in'}]
          outports: []
        <- p1.start          
        <- p2.start
        p2.ports.in.on 'message', -> it.should.be.eq 'hello'
        p2.ports.in.connect p1.ports.out.addr
        done!
