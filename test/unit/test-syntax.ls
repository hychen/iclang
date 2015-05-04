{syntax-validator} = ic.syntax!

describe 'Module Syntax', ->
  describe 'functions', ->
    describe 'syntax-validator(_type)', -> ``it``
      .. 'should be not case senstive.', (done) ->
        o1 = syntax-validator "component"
        o2 = syntax-validator "Component"
        o1.toJSON! .should.be.deep.eq o2.toJSON!
        done!
      .. 'should return a Component syntax validator', (done) ->
        syntax-validator "Component"
        done!
      .. 'should return a Module syntax validator', (done) ->
        syntax-validator 'Module'
        done!
      .. 'should return a HyperScript syntax validator', (done) ->
        syntax-validator 'HyperScript'
        done!
      .. 'should raise error if type is not supported', (done) ->
        expect(-> syntax-validator 'InvalidType').to.throw /Invalid Type/
        done!
