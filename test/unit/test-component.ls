{ensured-component-options, ensured-component, load-component, build-machine} = ic.component!

describe 'Module Component', ->
  describe 'functions', ->
    describe 'ensured-component-options(options)', -> ``it``
      .. 'should return the same object as input if input is valide', (done) ->
        o = ensured-component-options {a:1}
        o.should.deep.eq {a:1}
        done!
      .. 'should raise error if input is not an object', (done) ->
        expect(-> ensured-component-options 1).to.throw /TypeError: options/
        expect(-> ensured-component-options []).to.throw /TypeError: options/
        expect(-> ensured-component-options {}).to.not.throw /TypeError: options/
        done!
    describe 'ensured-component(component)', -> ``it``
      .. 'should return same object as input if input is valid.', (done) ->
        ori = do
          friendlyName: 'sum'
          description: 'sumup'
          fn: ->
        r = ensured-component ori
        r.should.be.deep.eq ori
        done!      
      .. 'should raise error if member `fn` is not a function.', (done) ->
        expect (-> ensured-component do
          friendlyName: 'sum'
          description: 'sumup'
          fn: 1) .to.throw /component.fn is not a function./
        done!
      .. 'should raise error if input is not valid.', (done) ->
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
    describe 'load-component(fpath)', -> ``it``
      .. 'should return a component', (done) ->
        comp = load-component './test/fixtures/components/mysum.ls'
        comp.inports.list.should.be.ok
        comp.outports.out.should.be.ok
        done!
      .. 'should raise error if js/ls file does not have provideComponent function', (done) ->
        expect(-> load-component './test/fixtures/components/invalid.ls').to.throw /... provideComponent/
        done!
    describe 'load-component(fpath, options)', -> ``it``
      .. 'should return a component', (done) ->
        done!
      .. 'should raise error if options is not valid', (done) ->
        expect(-> load-component './test/fixtures/components/mysum.ls', 1).to.throw /TypeError: options/
        done!
    describe 'build-machine(component)', -> ``it``
     .. 'should be able to build as a machine.' (done) ->
        comp = load-component './test/fixtures/components/mysum.ls'
        machine = build-machine comp
        machine.id.should.eq 'mysum'
        machine
          .configure {list:[1,2,3,4]}
          .exec (err, result ) ->
            result.should.deep.eq {out:10}
            done!