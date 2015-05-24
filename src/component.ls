## Module Component
#
# Description of `Component`
require! path
require! machine
{is-type} = require 'prelude-ls'
{syntax-validator} = require './syntax'

# --------------------------------------------
# Public Functions
# --------------------------------------------

# Takes component options and returns valid component options
#
# @param Object options - The component options
# @return Object - A valid options
export function ensured-component-options(options)
  #@TODO: check component options.
  throw new Error 'TypeError: options' unless is-type 'Object' options
  return options

# Takes a component and return valid component
#
# @param Object component - A component
# @raise Error - When component fn is not afunction
# @raise Error - When component is not valid
# @return Object - A valid component
export function ensured-component(component)
  unless component?
    throw new Error 'component is required'
  validate = syntax-validator 'Component'
  if validate component
    # JSON Schema does not support function type, we need
    # check it by ourself.
    if typeof component.fn is 'function'
      #@TODO: check component function signature.
      return component
    else
      throw new Error "component.fn is not a function."
  else
    throw validate.errors

# Takes a js/ls file path and return a component
#
# @param String fpath - The js/ls file path
# @param Object options - The component options
# @raise Error - When the file does not have provideComponent function
# @return Object - A component
export function load-component(fpath, options)
  mod = require path.resolve fpath
  unless mod.provide-component?
    throw "module loaded from #{fpath} does not have provideComponent function."

  if options
    options = ensured-component-options options
    defs = mod.provide-component options
  else
    defs = mod.provide-component null

  # @TODO: check definition
  return defs <<< do
    inports: defs.inputs or {}
    outports: defs.outputs or {}

# Takes a component and returns a Node machine
#
# @param Object component - The component
# @return Object - A Node machine
export function build-machine(component)
    return machine.build component
