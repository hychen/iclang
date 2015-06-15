/** Module Ports
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import PT = require('./Port');
import PTSD = require('./PortsDefinition');

export interface Ports {
    [key: string]: AnyPort;
}

interface AnyPort extends PT.Port {
    addr?: string;
    send?(data: Object);
    connect?(portAddr: string);
    on?(myevent: string, callback: (any) => any);
}

/**
 * Takes ports and returns its length.
 * @param {Object} ports - ports.
 * @returns {number}
 */
export function portsLength(ports: PTSD.PortsDefinition): number {
    return Object.keys(ports).length;
}
