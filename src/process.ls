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
{InPort, OutPort, ports-length} = require './port'

# --------------------------------------------
# Public Classes
# --------------------------------------------
export class Process

  # @param String name - The Process name
  # @param Component - an instance of Component
  # @return Process - an instance of Process
  (name, component, options) ->
    # -- Public Properties
    # @prop String name - The process name
    @name = name || throw 'process name is required'
    # @prop Object ports - The ports
    @ports = {}

    # -- Internal Properties
    @_status = 'initialzation'
    @_component = ensured-component component
    @_incoming = {}

    # -- Initialization
    @configure options

  # --------------------------------------------
  # Public Methods
  # --------------------------------------------

  # Takes options and change process behavior
  # 
  # @param Object - process config options
  # @example {'log-level': 'debug'}
  # @rais N/A
  # @returns N/A  
  #
  # Avaliable Options: 
  # - log-level : log level
  configure: (options) ->
    winston.level = options?.log-level or 'info'

  start: ->
    @_create-ports!
    @_status = 'running'    

  stop: ->
    @_destroy-ports!
    @_status = 'terminated'

  # --------------------------------------------
  # Internal Methods
  # --------------------------------------------

  # Create ports.
  _create-ports: ->
    winston.log 'debug', 'PROCESS: creating ports.'
    for let port-name, port-def of @_component.outports
      @ports[port-name] = new OutPort port-name
    for let port-name, port-def of @_component.inports
      @ports[port-name] = new InPort port-name
      @ports[port-name].on 'data', ~>
        @_incoming[port-name] = it
        # fire iff all required input collected.
        if ports-length(@_incoming) == ports-length @_component.inports
          @fire!

  # Destroy ports          
  _destroy-ports: ->
    winston.log 'debug', 'PROCESS: destroying ports.'
    for let _, port of @ports
      port.close!
