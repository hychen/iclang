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

length-ports = (ports) ->  
  Object.keys ports .length

export class Process extends events.EventEmitter

  (component) ->
    @_status = null
    @_component = null
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
    old-status = @status
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
      while @is-running!
        # polling codes here.
        console.log 'running'
    else
      throw new Error "process is not ready yet."

  stop: (done) ->
    @_deinit-sockets!
    @set-status 'stopped'
    done!

  _init-sockets: ->
    for port in @_component.inports
      @ports[port.name] = new Socket 'in', {name:port.name}
    for port in @_component.outports
      @ports[port.name] = new Socket 'out', {name:port.name}

  _deinit-sockets: ->
    for _, port of @ports
      port.sock.close!

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