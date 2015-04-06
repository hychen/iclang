require! events
require! fs
require! uuid
require! mkdirp
require! rimraf

{conf} = require '../lib/config'
{Socket} = require '../lib/socket'

RUNTIME_SOCKETS_DIR = conf.get 'RUNTIME_SOCKETS_DIR'

export function init-runtime-env(done)
  mkdirp RUNTIME_SOCKETS_DIR, done

export function clean-runtime-env(done)
  rimraf RUNTIME_SOCKETS_DIR, done

export function is-runtime-env-ready()
  fs.existsSync RUNTIME_SOCKETS_DIR

export function connect-port(src-process, src-port-name, dest-process, dest-port-name)
  throw 'source process is not valid.' unless src-process
  throw 'destination process is not valid.' unless dest-process
  src-port = src-process.ports[src-port-name]
  dest-port = dest-process.ports[dest-port-name]
  throw 'source port is not existed.' unless src-port
  throw 'destination port is not existed.' unless dest-port
  dest-port.connect src-port.addr 

length-ports = (ports) ->  
  Object.keys ports .length

export class Process extends events.EventEmitter

  (component) ->
    @_status = null
    @_component = null
    @_incoming = {}
    @ports = {}
    @id = uuid.v4!
    @set-status 'init'
    @set-component component

  is-ready: ->
    @_status is 'ready'

  is-running: ->  
    @_status is 'running'

  is-stopped: ->
    @_status is 'stopped'

  check-status: ->
    # ready iff required runtime environement is prepared
    # and a component is given.
    if @has-component! and is-runtime-env-ready!
      @set-status 'ready'
    # running if the sockets count is equal the count of components ports.
    # 0 sockets is valid case here.
    else if @is-ready! and length-ports @ports == @_component.inports.length + @_component.outportst.length
      @set-status 'running'
    # otherwise the process status is stopped.
    else
      @set-status 'stopped'

  set-status: (new-status) -> 
    old-status = @_status
    @_status = new-status
    @emit 'status-changed', old-status, new-status
    @emit "status:#{new-status}"

  status: ->
    @_status

  start: (done) ->
    if @is-ready!
      @_init-sockets!
      @set-status 'running'
      done @id
    else
      throw new Error "process is not ready yet."

  stop: (done) ->
    @_deinit-sockets!
    @set-status 'stopped'
    done!

  _init-sockets: ->
    for let port in @_component.inports
      @ports[port.name] = new Socket 'in', {name:port.name}
      @ports[port.name].on 'message', (data) ~>
        # collecting data.
        @_incoming[port.name] = data
        # fire iff all excpted data arrivied on sockets.
        # and flush the incoming queue.
        if Object.keys(@_incoming).length === @_component.inports.length
          @fire!
        else
          throw new Error 'edge case: length of incomfing data is smaller or larger than the length inports.' 
    for let port in @_component.outports
      @ports[port.name] = new Socket 'out', {name:port.name}

    # just fire if the component does not have any inports,
    # but its function may have output.    
    if @_component.inports.length == 0  and @_component.outports.length != 0
      @fire!

  _deinit-sockets: ->
    for _, port of @ports
      port.sock.close!

  fire: -> 
    dispath-result = (results) ~>
      #@TODO: should we need to check each values of results 
      # returned from component function does not be tagged?
      # it would be useful for debugging if we throw a error 
      # or warring here.      

      # send the results to outports if possible.
      for port-name, value of results
        if @ports[port-name]?
          @ports[port-name].send value    

    # flush incoming queue.
    fnargv = @_incoming
    @_incoming = {}

    if @_component.fn? and typeof @_component.fn is 'function'
      results = @_component.fn fnargv, do
        success: dispath-result
        error: console.error

  has-component: ->
    @_component?

  set-component: (component) ->
    if @is-ready!
      throw 'try to set a component on a process which is ready.'
    else
      @_component = component
      @check-status!

  component: ->
    @_component