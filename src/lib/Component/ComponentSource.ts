/** Module ComponentSource
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import CD = require('./ComponentDefinition');
import C = require('./Component');

/**
 * A component source represents a component in static time.
 * It includes a component definition and a componet provider.
 */
export interface ComponentSource {
    /** Component Definition */
    definition: CD.ComponentDefinition;
    /** Component Provider */
    provideComponent(options?: Object): C.Component;
}

/**
 * Loads a component source from a component source file.
 * @param {string} fpath - the path of a source file.
 * @returns {ComponentSource}
 * @throws {Error} when provideComponent function is not defined in the source file.
 */
export function loadComponentSource(fpath: string): ComponentSource {
    var mod = require(fpath);
    if(typeof mod.provideComponent != 'function')
        throw new Error('provideComponent function is not defined.');
    return mod;
}
