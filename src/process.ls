require! events
require! fs
require! uuid
require! mkdirp
require! rimraf

{conf} = require '../lib/config'

RUNTIME_SOCKETS_DIR = conf.get 'RUNTIME_SOCKETS_DIR'

export function init-runtime-env(done)
  mkdirp RUNTIME_SOCKETS_DIR, done

export function clean-runtime-env(done)
  rimraf RUNTIME_SOCKETS_DIR, done

export function is-runtime-env-ready()
  fs.existsSync RUNTIME_SOCKETS_DIR

export class Process extends events.EventEmitter

  (component) ->
    @_status = null
    @_component = null
    @id = uuid.v4!
    @set-status 'init'
    @set-component component
    
  is-ready: ->
    @_status is 'ready'

  check-status: ->
    # ready iff required runtime environement is prepared
    # and a component is given.
    if @has-component! and is-runtime-env-ready!
      @set-status 'ready'
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