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

  ->
    @_status = null
    @id = uuid.v4!
    @set-status 'init'

    # check required environement is ready.
    if is-runtime-env-ready!
      @set-status 'ready'
    # otherwise the process status is stopped.
    else
      @set-status 'stopped'

  is-ready: ->
    @_status is 'ready'

  set-status: (new-status) -> 
    old-status = @status
    @_status = new-status
    @emit 'status-changed', old-status, new-status
    @emit "status:#{new-status}"

  status: ->
    @_status