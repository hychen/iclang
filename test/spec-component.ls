should = require 'chai' .should!
expect = require 'chai' .expect

{load-component, ensured-component, build-machine} = require '../lib/component'

describe 'Component', ->
  describe 'is Node Machine compatable.', -> ``it``
    .. 'should be able to build as a machine.' (done) ->
      comp = load-component './test/fixture/components/mysum.ls'
      comp.inports.list.should.be.ok
      comp.outports.out.should.be.ok
      machine = build-machine comp
      machine.id.should.eq 'mysum'
      machine
        .configure {list:[1,2,3,4]}
        .exec (err, result ) ->
          result.should.deep.eq {out:10}
          done!
  describe.skip 'ensured-component-options()', ->
  describe 'ensured-component()', -> ``it``
    .. 'should check the accepted object is valid with component deifition JSON Schema.', (done) ->
      r = ensured-component do
        friendlyName: 'sum'
        description: 'sumup'
        fn: ->
      r.should.be.ok
      expect (-> ensured-component do
        friendlyName: 'sum'
        description: 'sumup'
        fn: 1) .to.throw /component.fn is not a function./

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
      expect (-> ensured-component {}) .to.throw expected
      done!
