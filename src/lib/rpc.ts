/** Module RPC
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import path = require('path');
import zerorpc = require('zerorpc');
import fs = require('fs');
import PS = require('./process');
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

export function rpcProcessPingMethod(unknown: any, reply: any) {
    reply(null, 'pong');
}

export function rpcProcessConfigureMethod(options: PS.ProcessOptions, unknown: any, reply: any) {
    var process: PS.Process;
    process = this;
    process.configure(options);
    reply();
}

export function rpcProcessConnectMethod(srcPortName: string, destProcessName: string, destPortName: string, unknown: any, reply: any){
    var process: PS.Process;
    process = this;
    // get remote out port address.
    controlRPCServer(destProcessName, 'inquery', PS.ProcessInquery.OutPortAddr, destPortName, (err, destPortAddr) =>{
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

export function controlRPCServer(processName: string, methodName: string, ...args: any[]) {
    // popup the callback function.
    var done: Function;
    done = args[args.length-1];
    delete(args[args.length]);
    // call remote RPC method.
    var processSockAddr = rpcSocketAddr(processName);
    if(fs.existsSync(processSockAddr)){
        var client = new zerorpc.Client();
        client.connect(`ipc://${processSockAddr}`);
        client.invoke(...args, (err, res, more) => {
            client.close();
            done(err, res, more);
        });
    }else{
        done(`remote process ${processName} is not running.`);
    }
}
