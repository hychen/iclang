/** Module Process
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
 import path = require('path');
 import C = require('./component');

/** Takes a process name and returns a ipc address.
 * @param {string}  processName - a process name.
 * @returns {string} ipc address.
 */
 export function rpcSocketAddr(processName: string): string {
    var runtimeDir = process.env.RUNTIME_ROOT_DIR || './.ic';
    var fname = 'ipc-process-' + processName;
    return path.join(runtimeDir, 'socket', fname);
 }

interface ProcessOptions {

}

export class Process {
    /** Process name */
    public name: string;
    /** Process options */
    public options: Object;
    /** Process ports **/
    public ports: Object;
    /** Process status */
    protected status: string;
    /** A reference to a instance of Component */
    protected component: C.ActComponent
                       | C.SourceActComponent
                       | C.PipeActComponent
                       | C.DestinationActComponent
    /** A queue to hold incoming data.*/
    protected incoming: Object;

    /** Create a Process.
     * @param {string} name - the name of a process.
     * @param {Component} component - a component.
     * @param {ProcessOptions} options - process options.
     */
    constructor(name: string,
                component: C.ActComponent
                         | C.SourceActComponent
                         | C.PipeActComponent
                         | C.DestinationActComponent,
                options?: ProcessOptions){
        this.name = name;
        this.status = 'initialzation'
        this.incoming = {};
        this.ports = {};
        this.component = component;
    }
}
