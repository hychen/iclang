/** Module Process
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import path = require('path');
import winston = require('winston');
import CM = require('../Common');
import C = require('../Component/Component');
import PT = require('../Port/Port');
import PTS = require('../Port/Ports');
import IPT = require('../Port/InPort');
import OPT = require('../Port/OutPort');
import PSCM = require('./Common');
import PSBPS = require('./BaseProcess');
import PSIMQ = require('./IncomingQueue');

export class Process extends PSBPS.BaseProcess {
    /** Process options */
    public ports: PTS.Ports;
    /** A reference to a instance of Component */
    protected component: C.Component;
    /** A queue to hold incoming data.*/
    protected incoming: PSIMQ.IncomingQueue;

    /** Create a Process.
     * @param {string} name - the name of a process.
     * @param {Component} component - a component.
     * @param {ProcessOptions} options - process options.
     */
    constructor(name: string,
                component: C.Component,
                options?: PSCM.ProcessOptions){
        super(name, options);
        this.incoming = {};
        this.ports = {};
        this.component = C.ensuredComponent(component);
    }

    /** Start the process.
     * @returns {void}
     */
    public start(){
        this.debug('starting.');
        this.createPorts();
        this.setStatus(PSCM.ProcessStatus.running);
        this.debug('started.');
    }

    /** Stop the process
     * @returns {void}
     */
    public stop(){
        this.debug('stopping.');
        this.setStatus(PSCM.ProcessStatus.terminating);
        this.destroyPorts();
        this.debug('stopped.');
    }

    /** Run the process
     * @returns {void}
     */
    public run(){
        var numInputs = PTS.portsLength(this.component['inputs']);
        if(numInputs == 0) {
            this.fireStream();
        }
    }

    /** Connects a source port to the address of a OutPort.
     * @praram {string} srcPortName - a inport name.
     * @param {string} destPortAddr - an ipc address of a outport.
     * @throws {Error} when the source port not exists.
     */
    public connect(srcPortName: string, destPortAddr: string) {
        this.ensuredRunning();
        var srcPort = this.ports[srcPortName];
        if(srcPort){
            if(!srcPort['addr']){
                srcPort.connect(destPortAddr);
                delete this.incoming[srcPortName];
            }else{
                this.error(`source port ${srcPortName} is not a InPort.`);
            }
        }else{
            this.error(`source port ${srcPortName} not exists`);
        }
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
            this.ports[portName] = new OPT.OutPort(portName);
            this.debug(`created an InPort '${portName}'`);
            numInPorts++;
        }
        for(var portName in this.component['inputs']){
            var portDef = this.component['inputs'][portName];
            self.ports[portName] = new IPT.InPort(portName);
            self.ports[portName].on('data', (data) => {
                self.debug(`recived data from ${portName}`, data);
                self.incoming[portName] = data;
                var numInputs = PTS.portsLength(this.component['inputs']);
                var numCollectedData = PSIMQ.collectedDataLength(this.incoming);
                if(numCollectedData === numInputs){
                    self.debug('firing rules satisfed, start to fire.');
                    this.fireStream();
                }
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

    /** Fires within token in stream
     */
    protected fireStream() {
        var self = this;
        this.debug('firing within token in the stream.');
        /** Helpers */

        /** Takes a component and returns callbacks that sending data
        * to attached port.
        * @param {Component} component - a component.
        * @returns {ExitCallbacks}
        */
        var componentExits = (component) => {
            var callbacks = {};
            for(var portName in component['exits']){
                callbacks[portName] = (data) => {
                    self.ports[portName].send(data);
                };
            }
            return callbacks;
        }
        /** Helpers ends. */

        // build exit callbacks from a given component.
        var exits = <CM.ExitCallbacks> componentExits(this.component);
        // always flush incoming queue when firing.
        var token = PSIMQ.collectedData(this.incoming);
        this.incoming = {};
        this.fireToken(token, exits);
    }

    /** Fires within token.
     * @param {Token} token - a data token.
     * @param {ExitCallbacks} - an object of callbacks.
     * @returns {any}
     * @throws {Error} when the process is not runnig.
     */
    public fireToken(token: CM.Token, exits: CM.ExitCallbacks) {
        this.debug('firing.', token);
        this.ensuredRunning();
        /** Each name of exit callbacks is valid if and only if it is the same
         * as the name defined in the component defintion.
         */
         for(var outPortName in this.component['exits']) {
            var exitFn = exits[outPortName];
            if(!exitFn){
                this.error(
                    `the exit callbacks does not contain ${outPortName} callback.`
                    );
            }
         }
        this.debug('invokes component function.', [token, exits]);
        var result = this.component.fn(token, exits);
        /** no matter the component function is executing or is not,
         * the process is able to fire again.
         *
         * [Note] this make the computing results are not in order.
         */
        this.setStatus(PSCM.ProcessStatus.running);
        /** returns resuits so we can check it in unit test.  */
        this.debug('fired.', result);
        return result;
    }

    /* Inquery the property of a process
     * @param {ProcessInquery} queryName - process inquery name.
     * @param {any} queryValue - inquery value.
     * @returns {any}
     */
    public inquery(queryId: PSCM.ProcessInquery, queryValue) {
        this.ensuredRunning();
        var queryName = PSCM.ProcessInquery[queryId];
        this.debug(`inquerying ${queryName}`, queryValue);
        if(queryId == PSCM.ProcessInquery.OutPortAddr){
            var portName = queryValue;
            var aPort = this.ports[portName];
            if(aPort){
                if(aPort.addr){
                    return aPort.addr;
                }else{
                    this.error(`Port ${portName} is not an OutPort.`);
                }
            }else{
               this.error(`Port ${portName} not exists.`);
            }
        }else{
            this.error(`Inquery ${queryName} is not supported`);
       }
    }
}
