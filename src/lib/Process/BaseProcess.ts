/** Module IC.Process.BaseProcess
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import path = require('path');
import winston = require('winston');
import PSCM = require('./Common');

export interface ProcessInterface {
    setStatus(status: PSCM.ProcessStatus);
    getStatus(): PSCM.ProcessStatus;
    isRunning(): boolean;
    configure(options: PSCM.ProcessOptions);
    start();
    stop();
}

export class BaseProcess implements ProcessInterface {
    /** Process name */
    public name: string;
    /** Process status */
    protected status: PSCM.ProcessStatus;
    /** A reference to Winston.LoggerInstance */
    protected logger: winston.LoggerInstance;
    /** Process options */
    protected options: PSCM.ProcessOptions;

    /**
     * Creates a Process.
     * @param {string} name - the name of a process.
     * @param {ProcessOptions} options - process options.
     */
    constructor(name: string,
                options?: PSCM.ProcessOptions){
        this.name = name;
        this.status = PSCM.ProcessStatus.initialzation;
        this.options = options || {};
        this.setLogger(this.options);
        this.configure(this.options);
    }

    /**
     * Sets process logger
     * @param {ProcessOptions}
     * @returns {void}
     */
    protected setLogger(options: PSCM.ProcessOptions) {
        var defaultLogFile = path.join(process.env.RUNTIME_LOG_DIR,
                                      `${this.name}.log`);

        var filePath = options['logFile'] ? options['logFile'] : defaultLogFile;
        var transports = [
                new winston.transports.File({filename: filePath})
        ]
        this.logger = new winston.Logger({transports: transports});
    }

    /**
     * Takes options and changes process behavior.
     * @param {ProcessOptions} - process options.
     * @returns {void}
     */
    public configure(options: PSCM.ProcessOptions) {
        var level = options['logLevel'] ? options['logLevel'] : 'info'
        this.logger['transports'].file.level = level;
    }

    /**
     * Gets the status
     * @returns {string} process status
     */
    public getStatus(): PSCM.ProcessStatus {
        return this.status;
    }

    /**
     * Sets the status
     * @param {string} status - process status
     */
    public setStatus(status: PSCM.ProcessStatus) {
        var oldStatus = this.status;
        var oldStatusLabel = PSCM.ProcessStatus[oldStatus];
        var newStatus = status;
        var newStatusLabel = PSCM.ProcessStatus[newStatus];
        this.debug(`Set new status ${oldStatusLabel} to ${newStatusLabel}`);
        this.status = newStatus;
    }

    /**
     * Checks if the process is running.
     * @returns {Boolean}
     */
    public isRunning(): boolean {
        return this.status === PSCM.ProcessStatus.running;
    }

    /**
     * Starts the process.
     * @returns {void}
     */
    public start(){
        this.debug('starting.');
        this.setStatus(PSCM.ProcessStatus.running);
        this.debug('started.');
    }

    /**
     * Stops the process
     * @returns {void}
     */
    public stop(){
        this.debug('stopping.');
        this.setStatus(PSCM.ProcessStatus.terminating);
        this.debug('stopped.');
    }

    /**
     * Ensures the process is running.
     * @throws {Error} when the process is not running.
     * @returns {void}
     */
    protected ensuredRunning(){
        if(!this.isRunning()){
            this.error("the process is not running");
        }
    }

    /**
     * Logs debug messages
     * @param {string} msg - a message.
     * @returns {void}
     */
    protected debug(msg: string, meta?: any) {
        this.logger.debug(`PROCESS: ${this.name} : ${msg}`, meta);
    }

    /**
     * Logs info messages
     * @param {string} msg - a message.
     * @returns {void}
     */
    protected info(msg: string) {
        this.logger.info(`PROCESS: ${this.name} : ${msg}`);
    }

    /**
     * Throws and logs error.
     * @param {string} msg - a message.
     * @param {meta} meta - an meta object (optional).
     * @returns {void}
     */
    protected error(msg: string, meta?: any) {
        var errMsg = `PROCESS ${this.name} : ${msg}`;
        this.logger.error(errMsg, meta);
        throw new Error(errMsg);
    }
}
