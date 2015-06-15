/** Module IC.Component.CompositedComponent
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import path =require('path');

export interface CompositedComponent {
    properties: {
        name: string
        description?: string,
        extendDescription?: string
    },
    import: {[key: string]: string};
    processes: {[key: string]: ProcessDefinition},
    connections: ConnectionDefinition[]
}

interface ProcessDefinition {
    component: string,
    options?: Object,
    inputs?: Object
}

interface ConnectionDefinition {
    src: {
        process: string,
        port: string
    },
    dest: {
        process: string
        port: string
    }
}

/**
 * Takes a file path and returns a composited component.
 * @param {string} fpath - path of a json file.
 * @returns {CompositedComponent}
 */
export function loadCompositedComponent(fpath: string): CompositedComponent {
    var root = path.dirname(fpath);
    var mod = require(fpath);
    // update absolute path of all components.
    for(var symbol in mod.import){
        mod.import[symbol] = path.resolve(root, mod.import[symbol]);
    }
    // @TODO: ensures the component is valid.
    return mod;
}
