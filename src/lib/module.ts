/** Module IC.Module
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import path = require('path');
import fs = require('fs');
import C = require('./Component/ComponentSource');

export interface Module {
    /* A reference to a json of module metadata. */
    meta: ModuleMeta;
    components: any;
    /* A commonjs module */
    commonjs?: Object;
}

interface ModuleMeta {
    /* the programming language name. */
    language: string;
    /* path of each components. */
    components: {[index: number]: string};
}

/**
 * Takes a directory path and returns a module meta.
 * @param {string} dpath - the absolute path of a directory.
 * @returns {IC.Module.ModuleMeta}
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

/**
 * Takes a directory path and returns a module.
 * @param {string} dpath - the path of a directory.
 * @returns {IC.Module.ModuleMeta}
 * @throws {Error} when a module is not supported.
 */
export function loadModule(dpath: string): Module {
    var dabspath = path.resolve(path.join(__dirname, dpath));
    var meta = loadModuleMeta(dabspath);
    var mod = <Module> {meta: meta, components: {}};
    if(meta.language == 'javascript'){
        for(var comp_path_idx in meta.components){
            var comp_path = meta.components[comp_path_idx];
            var comp_abspath = path.join(dabspath, comp_path);
            var symbol_name = path.basename(comp_path, '.js');
            mod.components[symbol_name] = C.loadComponentSource(comp_abspath);
        }
        mod.commonjs = require(dabspath);
        return mod;
    }else{
        throw new Error(`A module written in ${meta.language} is not supported.`);
    }
}
