should = require 'chai' .should!
expect = require 'chai' .expect

{load-component, ensured-component-definition} = require '../lib/component'

describe 'Component', ->
  describe 'is Node Machine compatable.', -> ``it``
    .. 'should be able to build as a machine.' (done) ->
      comp = load-component './test/fixture/components/mysum.ls'
      comp.inports.list.should.be.ok
      comp.outports.out.should.be.ok
      comp.machine.id.should.eq 'mysum'
      comp.machine
        .configure {list:[1,2,3,4]}
        .exec (err, result ) ->
          result.should.deep.eq {out:10}
          done!
  describe.skip 'ensured-component-options()', ->
  describe 'ensured-component-definition()', -> ``it``
    .. 'should check the accepted object is valid with component deifition JSON Schema.', (done) ->
      r = ensured-component-definition do
        friendlyName: 'sum'
        description: 'sumup'
        fn: ->
      r.should.be.ok
      expect (-> ensured-component-definition do
        friendlyName: 'sum'
        description: 'sumup'
        fn: 1) .to.throw /definition.fn is not a function./

      expected = [
        {
          "field": "data.friendlyName"
          "message": "is required"
        }
        {
          "field": "data.fn"
          "message": "is required"
        }
      ]      
      expect (-> ensured-component-definition {}) .to.throw expected
      done!
