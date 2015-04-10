should = require 'chai' .should!

{load-component} = require '../lib/component'

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
