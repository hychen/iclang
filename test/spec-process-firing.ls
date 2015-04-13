should = require 'chai' .should!

{Process, connect-port} = require '../lib/process'
{init-runtime-env, clean-runtime-env} = require '../lib/runtime'

describe 'Process Firing', ->
  beforeEach (done) ->
    <- clean-runtime-env    
    init-runtime-env done
  describe 'is executing the function of the component with recievied arguments on in sockets.', -> ``it``
    describe 'the component function without arguments.', ->
      .. 'should send the returned values of the function to outports.', (done) ->
        p1 = new Process do
          friendlyName: '' 
          inports: []
          fn: (_, exists) ->
            exists.success {out:'hello'}
          outports: {out:{}}
        p2 = new Process do          
          friendlyName: '' 
          inports: {in:{}}
          outports: []
          fn: ->
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
          friendlyName: '' 
          inports: []
          fn: (_, exists) ->
            exists.success {out: 'from-p1'}
          outports: {out:{}}
        p2 = new Process do
          friendlyName: '' 
          inports: []
          fn: (_, exists) ->
            exists.success {out: 'from-p2'}
          outports: {out:{}}
        p3 = new Process do
          friendlyName: '' 
          inports: {in1:{}, in2:{}}
          fn: (inputs) ->
            inputs.should.be.deep.eq {in:'from-p1', out:'from-p2'}
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