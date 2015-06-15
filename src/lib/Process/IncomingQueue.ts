/** Module Process.IncomingQueue
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import CM = require('../Common');

export interface IncomingQueue {

}

export function collectedDataLength(data: IncomingQueue): number {
    return Object.keys(data).length;
}

export function collectedData(data: IncomingQueue): CM.Token {
    return <CM.Token> data;
}
