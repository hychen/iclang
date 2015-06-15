/** Module RPC
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import path = require('path');
import zerorpc = require('zerorpc');
import fs = require('fs');
import PS = require('./Process/Process');
import PSINQ = require('./Process/ProcessInquery');
import C = require('./Component/Component');

/** Takes a process name and returns a ipc address.
 * @param {string}  processName - a process name.
 * @returns {string} ipc address.
 */
export function rpcSocketAddr(processName: string): string {
    var runtimeDir = process.env.RUNTIME_ROOT_DIR || './.ic';
    var fname = 'ipc-process-' + processName;
    return path.join(runtimeDir, 'socket', fname);
}

export function rpcProcessPingMethod(unknown: any, reply: any) {
    reply(null, 'pong');
}

export function rpcProcessConfigureMethod(options: PS.ProcessOptions, unknown: any, reply: any) {
    var process: PS.Process;
    process = this;
    process.configure(options);
    reply();
}

export function rpcProcessInqueryMethod(queryId: PSINQ.ProcessInquery, queryValue: any, unknown: any, reply: Function) {
    var process: PS.Process;
    process =  this;
    try{
        var result = process.inquery(queryId, queryValue);
        reply(null, result);
    }catch(error){
        reply(error);
    }
}

export function rpcProcessConnectMethod(srcPortName: string, destProcessName: string, destPortName: string, unknown: any, reply: any){
    var process: PS.Process;
    process = this;
    // get remote out port address.
    controlRPCServer(destProcessName, 'inquery', PSINQ.ProcessInquery.OutPortAddr, destPortName, (err, destPortAddr) =>{
        if(err)
            reply(err);
        else{
            var srcPort = process.ports[srcPortName];
            if(srcPort){
                try{
                    srcPort.connect(destPortAddr);
                    reply();
                }catch(error){
                    reply(error);
                }
            }else{
                reply(`source port ${srcPortName} not exists.`);
            }
        }
    });
}

/**
 * @param {string} processName - process name.
 * @param {Component} component - a component.
 * @param {ProcessOptions} options - process options.
 * @param {Function} done - callback.
 * @throws {Error} when process name is duplicated.
 */
export function createRPCServer(processName: string, component: C.Component, options: PS.ProcessOptions, done: Function) {
    var process = new PS.Process(processName, component, options);
    var processSockAddr = rpcSocketAddr(processName);
    /* zerorpc allows multiple rpc server bound on same ipc address
     * but in our case, each process and rpc server is 1-1 cooresponding.
     */
    if(fs.existsSync(processSockAddr)){
        throw new Error('Duplicated process name.');
    }
    var rpcServerAddr = `ipc://${processSockAddr}`;
    var processRPCContext = {
        ping: rpcProcessPingMethod.bind(process),
        configure: rpcProcessConfigureMethod.bind(process),
        inquery: rpcProcessInqueryMethod.bind(process),
        connect: rpcProcessConnectMethod.bind(process),
    };
    var server = new zerorpc.Server(processRPCContext);
    server.bind(rpcServerAddr);
    process.start();
    done(server, process);
}

export function controlRPCServer(processName: string, methodName: string, ...args: any[]) {
    // popup the callback function.
    var done: Function;
    done = args[args.length-1];
    delete(args[args.length-1]);
    // call remote RPC method.
    var processSockAddr = rpcSocketAddr(processName);
    if(fs.existsSync(processSockAddr)){
        var client = new zerorpc.Client();
        client.connect(`ipc://${processSockAddr}`);
        //@TODO: check if methodName is valid.
        client.invoke(methodName, ...args, (err, res, more) => {
            client.close();
            done(err, res, more);
        });
    }else{
        done(`remote process ${processName} is not running.`);
    }
}
