/** Module Component
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import CM = require('../Common');
import CD = require('./ComponentDefinition');
import CS = require('./ComponentSource');

export type Component
    = ActComponent
    | SourceActComponent
    | PipeActComponent
    | DestinationActComponent;

interface ActComponent extends CD.ComponentDefinition {
    fn: () => any;
}

interface SourceActComponent extends CD.ComponentDefinition {
    defaultExit?: string;
    exits: Object;
    fn: (inputs: CM.Token, exits: CM.ExitCallbacks) => any;
}

interface PipeActComponent extends CD.ComponentDefinition {
    inputs: Object;
    defaultExit?: string;
    exits: Object;
    fn: (inputs: CM.Token, exits: CM.ExitCallbacks) => any;
}

interface DestinationActComponent extends CD.ComponentDefinition {
    inputs: Object;
    fn: (inputs: CM.Token, exits: CM.ExitCallbacks) => any;
}

/**
 * Ensures a component is valid and normalized.
 * @param {Component} component - a component.
 * @returns {Component}
 */
export function ensuredComponent(component: Component): Component {
    if(component['inputs'] == null){
        component['inputs'] = {};
    }
    if(component['exits'] == null){
        component['exits'] = {};
    }
    return component;
}

/**
 * Loads a component from a component source file.
 * @param {string} fpath - the path of a source file.
 * @param {Object} options - options. (optional)
 * @returns {Component}
 * @throws {Error} when provideComponent function is not defined in the source file.
 */
export function loadComponent(fpath: string, options?: Object): Component {
    var mod = CS.loadComponentSource(fpath);
    if(options)
        return mod.provideComponent(options);
    else
        return mod.provideComponent();
}
