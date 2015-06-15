/** Module Process.Common
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
export enum ProcessStatus {
    initialzation,
    running,
    terminating
};

export interface ProcessOptions {
    /** logging level */
    logLevel? : string;
    /** loggin file path */
    logFile? : string;
}

export enum ProcessInquery {
    OutPortAddr
}
