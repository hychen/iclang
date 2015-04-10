require! path
require! machine

{syntax-validator} = require '../lib/syntax'

export function ensured-component-options(options)
  #@TODO: check component options.
  return options

export function ensured-component-definition(definition)
  validate = syntax-validator 'ComponentDefinition'
  if validate definition
    # JSON Schema does not support function type, we need 
    # check it by ourself.
    if typeof definition.fn is 'function'
      #@TODO: check component function signature.
      return definition
    else
      throw new Error "definition.fn is not a function."
  else
    throw validate.errors

export function load-component(fpath, options)
  mod = require path.resolve fpath  
  unless mod.provide-component?
    throw "module loaded from #{path} does not have provideComponent function."
  options = ensured-component-options options 
  defs = ensured-component-definition mod.provide-component options
  return defs <<< do
    inports: defs.inputs
    outports: defs.outputs
    machine: machine.build defs
