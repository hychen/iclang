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

  # Starts the process
  start: ->
    @_create-ports!
    @_status = 'running'    

  # Stop the process
  stop: ->
    @_destroy-ports!
    @_status = 'terminated'

  # Inquery property of a process.
  # @param {String} property name
  # @param {Any} query
  # @return {Any} result
  inquery: (prop-name, query) ->
    winston.log 'debug', "PROCESS: inquery #{prop-name} #{query}"
    match prop-name
    | /OutPortAddr/ => 
      port = @ports[query]
      throw "Port `#{query}` not exists." unless port?
      throw "Port `#{query}` is not a outport." unless port.addr?
      return port.addr
    | _ => throw "Inquery prop `#{prop-name}` is not supported."

  # Connects a source port to a outport address.
  #
  # @param {String} src-port-name - a in port name
  # @param {String} dest-port-addr - ipc address of a outport.
  # @raise {Error} when the port name isnt given
  # @raise {Error} when the dest-port-addr is not given
  # @raise {Error} when the port not exists
  # @raise {Error} when the port is not a inport
  connect: (src-port-name, dest-port-addr) ->
    winston.log 'debug', "PROCESS: connecting port `#{src-port-name} to #{dest-port-addr}."
    throw "source port name is required" unless src-port-name?
    throw "destination ipc address is required" unless dest-port-addr?
    throw "process is not running" unless @_status is 'running'
    src-port = @ports[src-port-name]
    throw "port `#{src-port-name}` not exists." unless src-port?
    throw "port `#{src-port-name}` is not a inport." if src-port.addr?
    src-port.connect dest-port-addr

  # Fires within token
  # 
  # @param {Object} token
  # @param {Object} exit callbacks
  fire-token: (token, exits) ->
    winston.log 'debug', "PROCESS: firing"
    # the process can not be fired if it is not running.
    throw new Error 'the process is not running' unless @_status is 'running'
    @_status = 'firing'

    winston.log 'debug', 'PROCESS: invoke component function.'      
    @_component.fn token, exits
    # no matter the component function is executing or is not, 
    # the process is able to fire again.
    # 
    # [Note] this make the computing results are not in order.
    @_status = 'running'    

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
          @_fire-stream!

  # Destroy ports          
  _destroy-ports: ->
    winston.log 'debug', 'PROCESS: destroying ports.'
    for let _, port of @ports
      port.close!

  # Firing within token from stream.
  _fire-stream: ->
    winston.log 'debug', 'PROCESS: fire within token from stream.'
    # -- Helpers

    # Takes a component and returns callbacks to send data to each outport.
    #
    # @param {Object} component - a component.
    # @return {Array} callbacks
    component-exits = (component) ~>
      callbacks = {}
      for let name, _ of component.outports
        callbacks[name] = ~>
          @ports[name].send it
      return callbacks

    # build exist callbacks defined by component.
    exits = component-exits @_component 
    # always flush incoming when firing.
    token = @_incoming 
    @_incoming = {}

    @fire-token token, exits