/** Module Test Helper
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
import path =require('path');
import mkdirp = require('mkdirp');
import rimraf = require('rimraf');

/** Initialize runtime environment for testing.
 * @param {(err: Error, made: string) => void} done - callback.
 */
export function initTestRuntimeEnv(done: (err: Error, made: string) => void) {
    mkdirp(global['TEST_RUNTIME_ROOT_DIR'], (err) => {
        if(err) throw err;
        mkdirp(global['TEST_RUNTIME_SOCKET_DIR'], done);
    });
}

/** Deinitialize runtime environment for testing.
 * @param {(err: Error) => void} done - callback.
 */
export function deinitTestRuntimeEnv(done: (err: Error) => void){
    rimraf(global['TEST_RUNTIME_ROOT_DIR'], () => {
        rimraf(global['TEST_RUNTIME_SOCKET_DIR'], done);
    });
}

/**
 * Takes a relative path of a fixture and returns its absolute path.
 * @param {string} anyPath
 * @returns {string}
 */
export function fixturePath(anyPath: string): string {
    var fixturesRoot = path.join(path.dirname(__filename),
                                 '../../',
                                 'fixtures');
    return path.join(fixturesRoot, anyPath);
}
