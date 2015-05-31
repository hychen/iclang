/** Module Port
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import path = require('path');
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
            throw new Error("runtime socket directory not exists.");
        }
    }else{
        throw new Error("runtime directory not exists.");
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

export class OutPort extends Port {

    /** The ipc address. */
    public addr: string;

    /** Create a new OutPort.
     * @param {string} id - The port name.
     * @returns {OutPort}
     */
    constructor(name: string) {
        super(name);
        /// Public Properties
        this.addr = portAddr(this.id);

        // Internal Properties
        this.setupSocket(zmq.socket('push'));

        // Initialization
        this.sock.bindSync(this.addr);
    }

    /** To send a JSON to the port it attached.
     * @param {Object} data - a JSON object.
     * @returns {void}
     * @throws {Error} throws by zmq.Socket if any.
     */
    public send(data: Object) {
        this.sock.send(JSON.stringify(data));
    }
}

export class InPort extends Port {

    /** Create a new InPort.
     * @param {string} name - The port name.
     * @returns {InPort}
     */
    constructor(name: string) {
        super(name);
        this.setupSocket(zmq.socket('pull'));
    }

    /** To connect to another OutPort
     *
     *  @param String portAddr - port ipc address
     *  @throws Error raised from zmq.Socket if any
     *  @returns Undeciable
     */
    public connect(portAddr: string) {
        var ipcPath = portAddr.replace('ipc://', '');
        if(fs.existsSync(ipcPath)){
            this.sock.connect(portAddr);
        }else{
            throw new Error(portAddr + 'not exists.');
        }
    }

    /** To regesiter a event handler.
     * @param {string} event - event name.
     * @param {Function} callback - event handler.
     * @returns {void}
     */
    public on(myevent: string, callback: (any) => any) {
        this.sock.on('message', (data) => {
            var realdata: string;
            try{
                realdata = JSON.parse(data.toString());
            }catch(SyntaxError){
                realdata = data.toString();
            }
            callback(realdata);
        });
    }
}
