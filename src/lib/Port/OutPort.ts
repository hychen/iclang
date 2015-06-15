/** Module OutPort
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import PT = require('./Port');
import zmq = require('zmq');

export class OutPort extends PT.Port {

    /** The ipc address. */
    public addr: string;

    /** Create a new OutPort.
     * @param {string} id - The port name.
     * @returns {OutPort}
     */
    constructor(name: string) {
        super(name);
        /// Public Properties
        this.addr = PT.portAddr(this.id);

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
