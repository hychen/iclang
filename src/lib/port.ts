import path = require('path');
import fs = require('fs');

/**
 * Takes a soceket id and returns a port ipc address.
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
