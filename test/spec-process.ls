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
  describe 'is ready iff required environment is prepared.', -> ``it``
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
