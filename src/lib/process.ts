/** Module Process
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
 import path = require('path');
 import winston = require('winston');
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
    public ports: Object;
    /** Process status */
    protected status: string;
    /** A reference to Winston.LoggerInstance */
    protected logger: winston.LoggerInstance;
    /** Process options */
    protected options: Object;
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
        this.setStatus('running');
        this.debug('started.');
    }

    /** Stop the process
     * @returns {void}
     */
    public stop(){
        this.debug('stopping.');
        this.setStatus('terminating');
        this.debug('stopped.');
    }

    /** To log debug messages
     * @param {string} msg - a message.
     * @returns {void}
     */
    protected debug(msg: string) {
        this.logger.debug(`PROCESS: ${this.name} : ${msg}`);
    }

    /** To log info messages
    * @param {string} msg - a message.
     * @returns {void}
     */
    protected info(msg: string) {
        this.logger.info(`PROCESS: ${this.name} : ${msg}`);
    }
}
