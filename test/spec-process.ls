should = require 'chai' .should!

{Process, init-runtime-env, clean-runtime-env} = require '../lib/process'

describe 'Process', ->
  beforeEach ->
    err <- clean-runtime-env
  describe 'has a unique identifier.', -> ``it``
    .. 'should be UUID.', (done) ->
     p1 = new Process 
     p2 = new Process
     p1.id.should.not.eq p2.id
     done!
  describe 'is ready iff required environment is prepared.', -> ``it``
    .. 'should have a runtime directory.', (done) ->
      p = new Process
      p.is-ready!.should.be.not.ok
      <- init-runtime-env
      p = new Process
      p.is-ready!.should.be.ok
      done!