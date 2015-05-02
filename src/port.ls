require! path
require! zmq
require! uuid

export function ports-names()
  return Object.keys it

export function ports-length()
  return ports-names it .length

port-addr = (proto, id) ->
  runtime-dir = process.env.RUNTIME_DIR or './.ic'
  "#{proto}#{path.join runtime-dir, 'socket', id}"

PortInterface = do

  close: ->
    @sock.close!

export class OutPort implements PortInterface

  (name) ->
    @id = uuid.v4!
    @name = name
    @addr = port-addr 'ipc://', @id
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