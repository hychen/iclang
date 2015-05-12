## Module RPC
#
# RPC server to control a process.
require! zerorpc
require! winston
require! path
require! fs

{Process} = require './process'

# --------------------------------------------
# Public Functions
# --------------------------------------------

# Takes a process name, component, options and returns a rpc server  
# 
# @param {String}
export function create-rpc-process(proc-name, component, options, done)
  process = new Process proc-name, component, options
  rpc-server-addr = "ipc://#{rpc-socket-addr proc-name}"
  
  # configure options
  winston.level = options?log-level or 'info'

  process-rpc-proto = do
    ping: (_, reply) ->
      reply null, 'pong'

  # create server
  server = new zerorpc.Server process-rpc-proto
  server.bind rpc-server-addr

  # After rpc server is running, 
  # so we can manage the process.
  process.start!
  done server, process

# Controls a remote process
export function control-rpc-process(proc-name, ...args)
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
    done "target process #{proc-name} is not running"

# Takes a process name and return a rpc server address.
#
# @param {String} process name
# @return {String} rpc server address
export function rpc-socket-addr(proc-name)
  runtime-dir = process.env.RUNTIME_DIR or './.ic'
  fname = "ipc-process-#{proc-name}"
  return path.join runtime-dir, 'socket', fname
