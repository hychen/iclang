/** Module Component
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
export interface ExitCallbacks {
    [key: string]: (any) => any;
}

interface BaseComponent {
    /* A display name for the component.
     * - Sentence-case (like a normal sentence)
     * - No ending punctuation.
     */
    friendlyName: string;
    /* Clear, 1 sentence description in the imperative mood.
     */
    description?: string;
    /* Provides supplemental info on top of description.
     */
    extendedDescription?: string;
    /**
     * This optional URL points to somewhere where additional information
     * about the underlying functionality in this component can be found.
     *
     * Be sure and use a fully qualified URL like http://foo.com/bar/baz.
     */
    moreInfoUrl?: string;
    // Can this component be cached?
    cacheable?: boolean;
    // Sync?
    sync?: boolean;
}

export interface ActComponent extends BaseComponent {
    fn: () => any;
}

export interface SourceActComponent extends BaseComponent {
    defaultExits?: string;
    exits: Object;
    fn: (inputs, exits: ExitCallbacks) => any;
}

export interface PipeActComponent extends BaseComponent {
    inputs: Object;
    defaultExits: string;
    exits: Object;
    fn: (inputs, exits: ExitCallbacks) => any;
}

export interface DestinationActComponent extends BaseComponent {
    inputs: Object;
    fn: (inputs, exits: ExitCallbacks) => any;
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
