/** Module Component
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
interface BaseComponent {
    friendlyName: string;
    description?: string;
}

export interface ActComponent extends BaseComponent {
    fn: () => any;
}

export interface SourceActComponent extends BaseComponent {
    defaultExits?: string;
    exits: Object;
    fn: (inputs, exits) => any;
}

export interface PipeActComponent extends BaseComponent {
    inputs: Object;
    defaultExits: string;
    exits: Object;
    fn: (inputs, exits) => any;
}

export interface DestinationActComponent extends BaseComponent {
    inputs: Object;
    fn: (inputs, exits) => any;
}

export type Component = ActComponent
                    | SourceActComponent
                    | PipeActComponent
                    | DestinationActComponent

export function ensuredComponent(component: Component): Component {
    if(component['inputs'] == null){
        component['inputs'] = {};
    }
    if(component['exits'] == null){
        component['exits'] = {};
    }
    return component;
}
