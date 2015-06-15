/** Module Port
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import path =require('path');
import fs = require('fs');
import uuid = require('node-uuid');
import zmq = require('zmq');

/**
 * Takes a socket id and returns a port ipc address.
 * @param {String} id - UUID v4 string.
 * @returns {String} - IPC address.
 */
export function portAddr(id:string){
    var runtimeDir = process.env.RUNTIME_ROOT_DIR || './.ic';
    var socketDir = path.join(runtimeDir, 'socket');
    if(fs.existsSync(runtimeDir)){
        if(fs.existsSync(socketDir)){
            return "ipc://" + path.join(socketDir, id);
        }else{
            throw new Error(`runtime socket directory ${socketDir} not exists.`);
        }
    }else{
        throw new Error(`runtime directory ${runtimeDir} not exists.`);
    }
}

export class Port {

    /** The port name. */
    public name: string;

    /** The port unique identifier. */
    public id: string;

    /** A reference to a zmq.Socket instance. */
    protected sock: zmq.Socket;

    /** Create a Port.
     * @param {string} id - The port name.
     * @returns OutPort
     */
    constructor(name: string) {
        this.name = name;
        this.id = uuid.v1();
    }

    public close(){
        this.sock.close();
    }

    /** To setup a sock of the port.
     * @param {zmq.Socket} sock - a zmq socket.
     * @returns {void}
     */
    protected setupSocket(sock: zmq.Socket){
        this.sock = sock;
    }
}
