/** Module Process
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
 import path = require('path');
 import winston = require('winston');
 import PT = require('./port');
 import C = require('./component');

var VALID_PROCESS_STATUSES = [
    'initialzation',
    'running',
    'terminating'
 ];

/** Takes a process name and returns a ipc address.
 * @param {string}  processName - a process name.
 * @returns {string} ipc address.
 */
 export function rpcSocketAddr(processName: string): string {
    var runtimeDir = process.env.RUNTIME_ROOT_DIR || './.ic';
    var fname = 'ipc-process-' + processName;
    return path.join(runtimeDir, 'socket', fname);
 }

interface ExitCallbacks {
    [key: string]: (any) => any;
}

interface Token {
    [key: string]: any;
}

interface IncomingQueue {

}

interface ProcessPorts {
    [key: string]: any;
}

interface ProcessOptions {
    /** logging level */
    logLevel? : string;
    /** loggin file path */
    logFile? : string;
}

export class Process {
    /** Process name */
    public name: string;
    /** Process options */
    public ports: ProcessPorts;
    /** Process status */
    protected status: string;
    /** A reference to Winston.LoggerInstance */
    protected logger: winston.LoggerInstance;
    /** Process options */
    protected options: ProcessOptions;
    /** A reference to a instance of Component */
    protected component: C.Component;
    /** A queue to hold incoming data.*/
    protected incoming: IncomingQueue;

    /** Create a Process.
     * @param {string} name - the name of a process.
     * @param {Component} component - a component.
     * @param {ProcessOptions} options - process options.
     */
    constructor(name: string,
                component: C.Component,
                options?: ProcessOptions){
        this.name = name;
        this.status = 'initialzation'
        this.incoming = {};
        this.ports = {};
        this.component = C.ensuredComponent(component);
        this.options = options || {};
        this.setLogger(this.options);
        this.configure(this.options);
    }

    /** Set process logger
     * @param {ProcessOptions}
     * @returns {void}
     */
    protected setLogger(options: ProcessOptions) {
        var defaultLogFile = path.join(process.env.RUNTIME_LOG_DIR,
                                      `${this.name}.log`);

        var filePath = options['logFile'] ? options['logFile'] : defaultLogFile;
        var transports = [
                new winston.transports.File({filename: filePath})
        ]
        this.logger = new winston.Logger({transports: transports});
    }

    /** Takes options and changes process behavior.
     * @param {ProcessOptions} - process options.
     * @returns {void}
     */
    public configure(options: ProcessOptions) {
        var level = options['logLevel'] ? options['logLevel'] : 'info'
        this.logger['transports'].file.level = level;
    }

    /** Get the status
     * @returns {string} process status
     */
    public getStatus(): string {
        return this.status;
    }

    /** Set the status
     * @param {string} status - process status
     */
    public setStatus(status: string) {
        var oldStatus = this.status;
        var newStatus = status;
        if(VALID_PROCESS_STATUSES.indexOf(newStatus) > -1 ) {
            this.debug(`Set new status ${oldStatus} to ${newStatus}`);
            this.status = newStatus;
        }else{
            this.debug(`Set new status ${oldStatus} to ${newStatus} - failed.`);
            throw new Error(`Invalid Status: ${newStatus}`);
        }
    }

    /** Check if the process is running.
     * @returns {Boolean}
     */
    public isRunning(): boolean {
        return this.status === 'running';
    }

    /** Start the process.
     * @returns {void}
     */
    public start(){
        this.debug('starting.');
        this.createPorts();
        this.setStatus('running');
        this.debug('started.');
    }

    /** Stop the process
     * @returns {void}
     */
    public stop(){
        this.debug('stopping.');
        this.setStatus('terminating');
        this.destroyPorts();
        this.debug('stopped.');
    }

    /** Creaet ports
     */
    protected createPorts() {
        var self = this;
        var numInPorts = 0;
        var numOutPorts = 0;
        this.debug('creating ports.');
        for(let portName in this.component['exits']){
            var portDef = this.component['exits'][portName];
            this.ports[portName] = new PT.OutPort(portName);
            this.debug(`created an InPort '${portName}'`);
            numInPorts++;
        }
        for(var portName in this.component['inputs']){
            var portDef = this.component['inputs'][portName];
            self.ports[portName] = new PT.InPort(portName);
            self.ports[portName].on('data', (data) => {
                self.incoming[portName] = data;
            });
            this.debug(`created an OutPort '${portName}'.`);
            numOutPorts++;
        }
        this.debug(`created ${numInPorts} InPort and ${numOutPorts} OutPort.`);
    }

    /** Destroy ports.
     */
    protected destroyPorts() {
        var numPorts = 0;
        this.debug('destroying ports.');
        for(var idx in this.ports){
            var aPort = this.ports[idx];
            aPort.close();
            this.debug(`close ports. ${aPort.name}`);
        }
        this.debug('destroyed ${numPorts} ports.');
    }

    /** Fires within token.
     * @param {Token} token - a data token.
     * @param {ExitCallbacks} - an object of callbacks.
     * @returns {any}
     * @throws {Error} when the process is not runnig.
     */
    public fireToken(token: Token, exits: ExitCallbacks) {
        this.debug('firing.', token);
        if(!this.isRunning()){
            var errMsg = "the process is not running";
            throw new Error(errMsg);
        }
        /** Each name of exit callbacks is valid if and only if it is the same
         * as the name defined in the component defintion.
         */
         for(var outPortName in this.component['exits']) {
            var exitFn = exits[outPortName];
            if(!exitFn){
                var errMsg = `the exit callbacks does not contain ${outPortName} callback.`;
                this.debug(errMsg, '');
                throw new Error(errMsg);
            }
         }
        this.debug('invokes component function.', [token, exits]);
        var result = this.component.fn(token, exits);
        /** no matter the component function is executing or is not,
         * the process is able to fire again.
         *
         * [Note] this make the computing results are not in order.
         */
        this.setStatus('running');
        /** returns resuits so we can check it in unit test.  */
        this.debug('fired.', result);
        return result;
    }

    /** To log debug messages
     * @param {string} msg - a message.
     * @returns {void}
     */
    protected debug(msg: string, meta?: any) {
        this.logger.debug(`PROCESS: ${this.name} : ${msg}`, meta);
    }

    /** To log info messages
    * @param {string} msg - a message.
     * @returns {void}
     */
    protected info(msg: string) {
        this.logger.info(`PROCESS: ${this.name} : ${msg}`);
    }
}
