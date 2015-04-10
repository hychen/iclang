require! fs
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