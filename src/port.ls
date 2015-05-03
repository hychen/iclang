## Module Port
#
# Description of `Port`
require! path
require! zmq
require! uuid
require! fs
{is-type} = require 'prelude-ls'

# --------------------------------------------
# Public Functions
# --------------------------------------------

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
  if fs.existsSync runtime-dir
    socket-dir = path.join runtime-dir, 'socket'
    if fs.existsSync socket-dir
      "ipc://#{path.join socket-dir, id}"
    else
      throw new Error 'runtime socket directory not exists.'
  else
    throw new Error 'runtime directory not exists.'

# --------------------------------------------
# Internal Interfaces
# --------------------------------------------
PortInterface = do

  # Close the port
  #
  # @param N/A
  # @raise Erro raised from zmq.socket if any
  # @return Undeciable
  close: ->
    @sock.close!

# --------------------------------------------
# Public Classes
# --------------------------------------------
export class OutPort implements PortInterface

  # @param String name - The OutPort name
  # @return OutPort - The OutPort instance
  (name) ->
    # -- Public Properties
    # @prop String id - The identifier in UUID v4 format
    @id = uuid.v4!
    # @prop String name - The port name
    @name = name
    # @prop String addr - The port ipc address where other ports can connect
    @addr = port-addr @id

    # -- Internal Properties
    @sock = zmq.socket 'push'

    # -- Initialization 
    @sock.bindSync @addr

  # --------------------------------------------
  # Public Methods
  # --------------------------------------------

  # To send a JSON to the port it attached.
  #
  # @param JSON data
  # @raises Error raised from zmq.Socket if any
  # @return Undeciable
  send: (data) ->
    @sock.send JSON.stringify data

export class InPort implements PortInterface

  (name, options) ->
    # -- Public Properties    
    # @prop String name - The port name
    @name = name

    # -- Internal Properties    
    @sock = zmq.socket 'pull'    

  # --------------------------------------------
  # Public Methods
  # --------------------------------------------

  # To connect to another OutPort
  #
  # @param String port-addr - port ipc address
  # @raises Error raised from zmq.Socket if any
  # @return Undeciable
  connect: (port-addr) ->
    @sock.connect port-addr

  # To handle the event
  #
  # @param String event - event name
  # @param Function callback - event handler
  # @return Undeciable
  # @event `data` - emit JSON when data received
  # @event `error` - emit Error if any error happen
  on: (event, callback) ->
    match event
    | /data/ =>
      @sock.on 'message', ->
       callback JSON.parse it.toString! 
    | _ => 
      @sock event, callback