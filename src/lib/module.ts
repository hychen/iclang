/** Module Module
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import path = require('path');
import fs = require('fs');
import C = require('./component');

export interface ModuleMeta {
    /* the programming language name. */
    language: string;
    /* path of each components. */
    components: {[index: number]: string};
}

export interface Module {
    /* A reference to a json of module metadata. */
    meta: ModuleMeta;
    /* A commonjs module */
    commonjs?: Object;
}

/** To takes a directory path and returns a module meta.
 * @param {string} dpath - the absolute path of a directory.
 * @returns {ModuleMeta}
 */
function loadModuleMeta(dabspath: string): ModuleMeta {
    var metadata_path = path.join(dabspath, 'metadata.json');
    var meta = require(metadata_path);
    meta.language = meta.language.toLowerCase();
    for(var comp_path of meta.components){
        var comp_abspath = path.join(dabspath, comp_path);
        if(!fs.existsSync(comp_abspath))
            throw new Error(`component ${comp_path} not exists.`);
    }
    return meta;
}

/** To takes a directory path and returns a module.
 * @param {string} dpath - the path of a directory.
 * @returns {Module}
 * @throws {Error} when a module is not supported.
 */
export function loadModule(dpath: string): Module {
    var dabspath = path.resolve(path.join(__dirname, dpath));
    var meta = loadModuleMeta(dabspath);
    var mod = <Module> {meta: meta};
    if(meta.language == 'javascript'){
        mod.commonjs = require(dabspath);
        return mod;
    }else{
        throw new Error(`A module written in ${meta.language} is not supported.`);
    }
}
