require! path
require! zmq
require! uuid

ports-names = ->
  return Object.keys it

ports-length = ->
  return ports-names it .length

port-addr = (proto, runtime-dir, id) ->
  "#{proto}#{path.join runtime-dir, 'socket', id}"

PortInterface = do

  close: ->
    @sock.close!

export class OutPort implements PortInterface

  (definition, options) ->
    @id = uuid.v4!
    @definition = definition
    @addr = port-addr 'ipc://', options.runtime-dir, @id
    @sock = zmq.socket 'push'
    @sock.bindSync @addr

  send: (data) ->
    @sock.send JSON.stringify data

export class InPort implements PortInterface

  (definition, options) ->
    @definition = @definition
    @sock = zmq.socket 'pull'    

  connect: (port) ->
    @sock.connect port.addr

  on: (event, callback) ->
    match event
    | /data/ =>
      @sock.on 'message', ->
       callback JSON.parse it.toString! 
    | _ => 
      @sock event, callback