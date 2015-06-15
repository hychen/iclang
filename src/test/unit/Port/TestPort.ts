/** Module Port Unit Tests.
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
/// <reference path="../../bootstrap-test.d.ts" />
import rimraf = require('rimraf');
import PT  = require('../../../lib/Port/Port');
import HELP = require('../../helper');

describe('function portAddr()', () => {
    beforeEach((done) => {
        HELP.initTestRuntimeEnv(done);
    });
    afterEach((done) => {
        HELP.deinitTestRuntimeEnv(done);
    });
    it('accepts a uuid v4 string and returns an ipc address.', (done) => {
        var addr = PT.portAddr('ggg');
        expect(addr).to.match(/ipc:\/\//);
        expect(addr).to.match(/\.ic\/socket\/ggg/);
        done();
    });
    it('raises error if runtime directory not exists', (done) => {
        rimraf(global['TEST_RUNTIME_ROOT_DIR'], () => {
            expect(() => PT.portAddr('yooo'))
                .to.throw(/runtime directory.*not exists./);
            done();
        });
    });
    it('raises error if runtime socket directory not exists', (done) => {
        rimraf(global['TEST_RUNTIME_SOCKET_DIR'], () => {
            expect(() => PT.portAddr('yooo'))
                .to.throw(/runtime socket directory.*not exists./);
            done();
        });
    });
});
