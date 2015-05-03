require! path
require! zmq
require! uuid
{is-type} = require 'prelude-ls'

# Takes a set of ports and returns port name ame
#
# @param {String:a} ports - The ports
# @raise Error - When port is not an object.
# @return [String] - A list of port name
export function ports-names(ports)
  if is-type 'Object' ports
    Object.keys ports
  else 
    throw new Error "ports is not an object."

# Takes a set of ports and returns count of ports.
#
# @param {String:a} ports - The ports
# @raise Error - When port is not an object.
# @return Number - The count of ports.
export function ports-length(ports)
  return ports-names ports .length

# Takes a soceket id and returns a port ipc address.
#
# @param String id - A socket id in uuid v4 string format.
# @return String - The port ipc address.
export function port-addr(id)
  runtime-dir = process.env.RUNTIME_DIR or './.ic'
  "ipc://#{path.join runtime-dir, 'socket', id}"

PortInterface = do

  close: ->
    @sock.close!

export class OutPort implements PortInterface

  (name) ->
    @id = uuid.v4!
    @name = name
    @addr = port-addr @id
    @sock = zmq.socket 'push'
    @sock.bindSync @addr

  send: (data) ->
    @sock.send JSON.stringify data

export class InPort implements PortInterface

  (name, options) ->
    @name = name
    @sock = zmq.socket 'pull'    

  connect: (port-addr) ->
    @sock.connect port-addr

  on: (event, callback) ->
    match event
    | /data/ =>
      @sock.on 'message', ->
       callback JSON.parse it.toString! 
    | _ => 
      @sock event, callback