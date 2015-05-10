## Module Process
#
# Description of `Process`
require! events
require! path
require! zerorpc
require! fs
require! mkdirp
require! winston

{ensured-component} = require './component'

# --------------------------------------------
# Public Classes
# --------------------------------------------
export class Process

  # @param String name - The Process name
  # @param Component - an instance of Component
  # @return Process - an instance of Process
  (name, component) ->
    # -- Public Properties
    # @prop String name - The process name
    @name = name || throw 'process name is required'
    # @prop Component - an instance of Component
    @component = ensured-component component

    # -- Internal Properties
    @_status = 'initialzation'

    # -- Initialization

