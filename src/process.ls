require! events
require! path
require! zerorpc
require! fs
require! mkdirp
require! winston

{load-component, ensured-component} = require './component'

VALID_PROCESS_STATUS = <[
    initializing
    ready
    running
    terminated
    suspend    
  ]>

export function rpc-socket-addr(proc-name)
  fname = "ipc-process-#{proc-name}"
  return path.join './.ic/sock', fname

export function start-process(component-name-or-path, proc-name)
  err <- mkdirp './.ic/sock'
  throw err if err
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
    @_init-rpc!
    @_init-event-handlers!

  # -------------------------------------
  # Public Methods
  # -------------------------------------
  status: ->
    @_status

  start: ->
    rpc-server-addr = "ipc://#{rpc-socket-addr @name}"
    winston.log 'debug',  "PROCESS: starting RPC server on #{rpc-server-addr}"
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