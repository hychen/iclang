require! path
require! machine

export function ensured-component-options(options)
  #@TODO: check component options.
  return options

export function ensured-component-definition(definition)
  #TODO: check component.
  return definition

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
