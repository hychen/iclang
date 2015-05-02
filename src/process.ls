require! events
require! path
require! zerorpc
require! fs
require! mkdirp
require! winston

{load-component, ensured-component} = require './component'
{InPort, OutPort} = require './port'

VALID_PROCESS_STATUS = <[
    initializing
    ready
    running
    firing
    terminated
    suspend    
  ]>

export function rpc-socket-addr(proc-name)
  runtime-dir = process.env.RUNTIME_DIR or '././ic'
  fname = "ipc-process-#{proc-name}"
  return path.join runtime-dir, 'socket', fname

export function start-process(component-name-or-path, proc-name)
  component = load-component component-name-or-path, {}
  p = new Process proc-name
  p.start!
  return p

export function control-process(proc-name, ...args)
  # popup the callback function.
  done = args[args.length-1]
  delete args[args.length-1]
  # call remote RPC method.
  proc-sock-addr = rpc-socket-addr proc-name
  if fs.existsSync proc-sock-addr
    client = new zerorpc.Client!
    client.connect "ipc://#{proc-sock-addr}"
    err, res, more <- client.invoke ...args
    client.close!
    done err, res, more
  else
    console.log "source process #{proc-name} is not running"

export class Process extends events.EventEmitter

  (name)->
    # -------------------------------------
    # Public Properties
    # -------------------------------------    
    @name = name

    # -------------------------------------    
    # Internal Properties
    # -------------------------------------    
    @_status = 'initializing'
    @_rpc-server = null
    @_rpc-protocol = do
      status: (_, reply) ~>
        winston.log 'debug',  "RPC: status()"
        reply null, @status!
      run: (_, reply)  ~>
        winston.log 'debug',  "RPC: run()"
        @run! 
        reply!
      pause: (_, reply)  ~>
        winston.log 'debug',  "RPC: pause()"
        @pause!
        reply!
      connect: (src-port, dest-port, _, reply) ~>
        winston.log 'debug',  "RPC: connect(#{src-port}, #{dest-port})"
        reply!    

    # -------------------------------------    
    # Initializations
    # -------------------------------------    
    @_init-event-handlers!

  # -------------------------------------
  # Public Methods
  # -------------------------------------
  status: ->
    @_status

  start: ->
    rpc-server-addr = "ipc://#{rpc-socket-addr @name}"
    winston.log 'debug',  "PROCESS: starting RPC server on #{rpc-server-addr}"
    @_init-rpc!    
    @_rpc-server.bind rpc-server-addr
    @_set-status 'ready'    

  stop: ->
    @_rpc-server._socket.close!
    @_set-status 'terminated'

  run: ->
    if @status! is 'ready'
      @_set-status 'running'
    else
      throw new Error "process is #{@status!} and can not enter running mode. "

  pause: ->
    if @status! is 'running'
      @_set-status 'suspend'
    else
      throw new Error "process is #{@status!} and can not enter suspend mode."

  # -------------------------------------
  # Internal Methods
  # -------------------------------------
  _set-status: (new-status) ->
    old-status = @_status
    if new-status in VALID_PROCESS_STATUS
      @_status = new-status
      @emit 'internal:status-changed', old-status, new-status
    else
      throw new Error "set process into invalid status: #{new-status}."

  _init-rpc: ->
    @_rpc-server = new zerorpc.Server @_rpc-protocol

    @_rpc-server.on 'error', ->
      console.error "RPC: Error: #{it}"

  _init-event-handlers: ->
    @on 'internal:status-changed', (old-status, new-status) ->
      winston.log 'debug', "EVENT: status-changed: #{old-status} -> #{new-status}"
      @emit 'status-changed'

    # process will be graceful terminating when it received
    # SIGTERM or SIGINT.
    process.on 'SIGTERM', ~>
      winston.log 'debug', "SIG: SIGTERM received"
      @stop!

    process.on 'SIGINT', ~>
      winston.log 'debug', "SIG: SIGINT received"
      @stop!

export class WorkerProcess extends Process

  (name, component) ->
    super name
    # -------------------------------------
    # Public Properties
    # -------------------------------------
    @ports = {}

    # -------------------------------------    
    # Internal Properties
    # -------------------------------------     
    @_component = ensured-component component
    @_incoming = {}
    @_rpc-protocol <<< do
      fire: (token, _, reply) ~>
        winston.log 'debug',  "RPC: fire()"
        @fire token, do
          success: (result) ->
            winston.log 'debug',  "RPC: fire() success"
            reply null, result
          error: (error)->
            winston.log 'debug',  "RPC: fire() error"
            reply error

    # -------------------------------------    
    # Initializations
    # -------------------------------------    

  # -------------------------------------
  # Public Methods
  # -------------------------------------
  start: ->
    @_init-ports!
    super!

  stop: ->    
    @_deinit-ports!
    super!

  fire: (token, rpc-exits) ->
    # ---------------------
    # Helper functions start.
    # ---------------------
    process-exits = do
      # when component function executes success, 
      # process send each value in the result to properly port.
      success: (token) ~>
        for let port-name, value of token
          @ports[port-name].send value
      # when component funciton executes failed with unexcpted error,
      # process print the error message to console.
      error: -> 
        console.error it
    # ---------------------
    # Helper functions end.        
    # ---------------------
    current-status = @status! 

    # if token is given, the process is fired by RPC command.
    if token?
      winston.log 'debug', 'PROCESS: fired by RPC.'
      data = token
      exits = do
        success: -> 
          process-exits.success it
          rpc-exits.success it
        error: -> rpc-exits.error it
    # else the process is fired when firing rule is stastify.
    else
      winston.log 'debug', 'PROCESS: fired by Firing Rule.'
      data = @_incoming
      exits = process-exits

    # the process can not be fired if it is not under running mode.
    if current-status isnt 'running'
      winston.log 'debug', 'PROCESS: skip firing because the process is not running.'
    else
      @_set-status 'firing'
      # always flush incoming queue when firing.
      @_incoming = {}

      # invoke component function.
      winston.log 'debug', 'PROCESS: invoke component function.'
      result = @_component.fn data, exits
      # no matter the component function is executing or is not, 
      # the process is able to fire again.
      # 
      # [Note] this make the computing results are not in order.
      @_set-status 'running'

  # -------------------------------------
  # Internal Methods
  # -------------------------------------
  _init-ports: ->
    winston.log 'debug', 'PROCESS: initializing ports.'
    for let port-name, port-def of @_component.outports
      @ports[port-name] = new OutPort port-name
    for let port-name, port-def of @_component.inports
      @ports[port-name] = new InPort port-name
      @ports[port-name].on 'data', ->
        @_incoming[port-name] = it
        # fire iff all required input collected.
        if ports-length @_incoming == ports-length @_component.inports
          @fire!

  _deinit-ports: ->
    winston.log 'debug', 'PROCESS: deinitializing ports.'
    for let port in @ports
      port.clos!
