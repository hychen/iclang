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
      winston.log 'debug', 'RPC: Ping'
      reply null, 'pong'
    configure: (cfg, _, reply) ->
      winston 'debug', 'RPC: Configure'
      process.configure(cfg)
      reply!
    inquery: (prop-name, query, _, reply) ->
      winston.log 'debug', "RPC: Start to inquery #{prop-name}, query: #{query}"
      try
        res = process.inquery prop-name, query
        winston.log 'debug', "RPC: Success to inquery #{prop-name}, query: #{query}, result: #{res}"
        reply null, res
      catch error
        winston.log 'debug', "RPC: Fail to inquery #{prop-name}, query: #{query}"
        reply error
    connect: (src-port-name, dest-proc-name, dest-port-name, _, reply) ->
      winston.log 'debug', "RPC: Start to connect #{src-port-name} to #{dest-proc-name}:#{dest-port-name}"
      err, dest-port-addr, _ <- control-rpc-process dest-proc-name, 'inquery', 'OutPortAddr', dest-port-name
      if err
        winston.log 'debug', "RPC: Can not get #{dest-port-name} address. #{err.message}"
        reply err
      else
        winston.log 'debug', "RPC: Got #{dest-port-name} address."
        src-port = process.ports[src-port-name]
        if src-port
          winston.log 'debug', "RPC: Port #{src-port-name} found"
          try
            src-port.connect dest-port-addr
            winston.log 'debug', "RPC: #{src-port-name} connected to #{dest-port-addr}"
            reply!
          catch error
            winston.log 'debug', "RPC: Port #{src-port-name} connect to dest-port-addr failed."
            reply error
        else
          winston.log 'debug', "RPC: Port #{src-port-name} not found"
          reply "source port `#{src-port-name}` not exists"
    fire: (token, _, reply) ->
      exists = do
        success: (result) ->
          winston.log 'debug',  "RPC: fire() success"
          reply null, result
        error: (error) ->
          winston.log 'debug',  "RPC: fire() error"
          reply error
      try
        process.fire-token token, exists
      catch error
        reply error

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
