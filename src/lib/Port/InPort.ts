/** Module InPort
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import fs = require('fs');
import zmq = require('zmq');
import PT = require('./Port');

export class InPort extends PT.Port {

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
