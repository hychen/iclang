require! path
require! zmq
require! uuid

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
