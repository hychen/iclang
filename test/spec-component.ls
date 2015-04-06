should = require 'chai' .should!

require! machine

export function ensured-component-options(options)
  #@TODO: check component options.
  return options

export function ensured-component-definition(definition)
  #TODO: check component.
  return definition

export function load-component(path, options)
  mod = require path  
  unless mod.provide-component?
    throw "module loaded from #{path} does not have provideComponent function."
  options = ensured-component-options options 
  defs = ensured-component-definition mod.provide-component options
  return defs <<< do
    inports: defs.inputs
    outports: defs.outputs

describe 'Component', ->
  describe 'is Node Machine compatable.', -> ``it``
    .. 'should be able to build as a machine.' (done) ->
      comp = load-component './fixture/components/mysum.ls'
      comp.inports.list.should.be.ok
      comp.outports.out.should.be.ok
      M = machine.build comp
      M.id.should.eq 'mysum'
      M
        .configure {list:[1,2,3,4]}
        .exec (err, result ) ->
          result.should.deep.eq {out:10}
          done!
