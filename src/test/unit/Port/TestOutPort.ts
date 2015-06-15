/** Module OutPort Unit Tests.
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
/// <reference path="../../bootstrap-test.d.ts" />
import OPT  = require('../../../lib/Port/OutPort');
import HELP = require('../../helper');

describe('class OutPort', () => {
    beforeEach((done) => {
        HELP.initTestRuntimeEnv(done);
    });
    afterEach((done) => {
        HELP.deinitTestRuntimeEnv(done);
    });
    describe('#constructor(name)', () => {
        check.it('accepts a string ane returns a OutPort instance.)', {maxSize:10}, [gen.string], (name) => {
            var aPort = new OPT.OutPort(name);
            expect(aPort.name).to.eq(name);
            expect(aPort.id).to.be.ok;
        });
    });
});
