require! mkdirp
require! rimraf
require! path

{Process} = ic.process!

describe 'Module Process', ->
  describe 'class Process', -> 
    describe '#constructor(name, component)', -> ``it`` 
      .. 'should raise error if the name is not valid.', (done) ->
        expect(-> new Process).to.throw 'process name is required'
        done!
      .. 'should raise error if the component is not valid.', (done) ->
        expect(-> new Process 'hello').to.throw 'component is required'
        done!