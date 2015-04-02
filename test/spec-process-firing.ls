should = require 'chai' .should!

{Process, init-runtime-env, clean-runtime-env, connect-port} = require '../lib/process'

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
        connect-port p1, 'out', p2, 'in'
        <- p1.stop!
        <- p2.stop!
        done!
      .. 'should fire iff all data arrives in sockets.', (done) ->
        <- init-runtime-env 
        p1 = new Process do
          inports: []
          fn: ->
            {out:'hello'}
          outports: [{name:'out'}]
        p2 = new Process do          
          inports: [{name: 'a1'}, {name: 'a2'}]
          fn: (inports) ->
            console.log inports
          outports: []
        <- p1.start          
        <- p2.start
        connect-port p1, 'out', p2, 'a1'
        <- p1.stop!
        <- p2.stop!
        done!        