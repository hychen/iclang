require! zmq
require! uuid

{conf} = require '../lib/config'

RUNTIME_SOCKETS_DIR = conf.get 'RUNTIME_SOCKETS_DIR'

export class Socket 

  (direction, name) ->
    @id = uuid.v4!
    @name = name
    @direction = direction
    @addr = null
    @sock = null
    @connected = false

    switch direction
      | 'in' => 
        @sock = zmq.socket 'sub'
      | 'out' => 
        @sock = zmq.socket 'pub'
        @addr = "ipc://#{RUNTIME_SOCKETS_DIR}/#{@id}"
        @sock.bindSync @addr
      | _ => throw new Error 'invalid direction'

  is-connected: ->
    @connected == true

  connect: -> 
    @connected = true
    @sock.connect it

  disconnect: ->
    @connected = false

  close: ->
    @sock.close!

  send: (data) ->
    if @direction is 'out'
      @sock.send JSON.stringify data
    else 
      throw new Error 'try to send data on in socket.'

  on: (event-name, handler) ->
    @sock.on event-name, (msg) -> 
      data = JSON.parse msg
      handler data
