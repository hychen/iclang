should = require 'chai' .should!

{Process, init-runtime-env, clean-runtime-env, connect-port} = require '../lib/process'

describe 'Process Firing', ->
  beforeEach ->
    <- init-runtime-env 
  afterEach ->
    <- clean-runtime-env
  describe 'is executing the function of the component with recievied arguments on in sockets.', -> ``it``
    describe 'the component function without arguments.', ->
      .. 'should send the returned values of the function to outports.', (done) ->
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
        p2.ports.in.on 'message', -> 
          it.should.be.eq 'hello'
          <- p1.stop
          <- p2.stop
        connect-port p1, 'out', p2, 'in'
        done!
  describe 'the component function with arguments', -> ``it``
    .. 'should only be executed iff all wanted data arrived on in sockets.', (done) ->
        p1 = new Process do
          inports: []
          fn: ->
            {out: 'from-p1'}
          outports: [{name: 'out'}]
        p2 = new Process do
          inports: []
          fn: ->
            {out: 'from-p2'}
          outports: [{name: 'out'}]
        p3 = new Process do
          inports: [{name:'in1'}, {name:'in2'}]
          fn: (inports) ->
            inports.should.be.deep.eq {in:'from-p1', out:'from-p2'}
            <- p1.stop
            <- p2.stop
            <- p3.stop
          outports: []            
        <- p1.start            
        <- p2.start
        <- p3.start
        connect-port p1, 'out', p3, 'in1'
        connect-port p2, 'out', p3, 'in2'
        done!