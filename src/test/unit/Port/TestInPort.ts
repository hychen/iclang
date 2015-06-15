/** Module InPort Unit Tests.
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
/// <reference path="../../bootstrap-test.d.ts" />
import zmq = require('zmq');
import uuid = require('node-uuid');
import IPT  = require('../../../lib/Port/InPort');
import HELP = require('../../Helper');

describe('class InPort', () => {
    beforeEach((done) => {
        HELP.initTestRuntimeEnv(done);
    });
    afterEach((done) => {
        HELP.deinitTestRuntimeEnv(done);
    });
    describe('#constructor(name)', () => {
        check.it('accepts a string ane returns a OutPort instance.)',
                {maxSize:10}, [gen.string],
                (name) => {
                    var aPort = new IPT.InPort(name);
                    expect(aPort.name).to.eq(name);
                    expect(aPort.id).to.be.ok;
        });
    });
    describe('#connect(portAddr)', () => {
        it('thorws error if portAddr is not exists.', (done) => {
            var aPort = new IPT.InPort('in');
            expect(() => aPort.connect(uuid.v1())).to.throw(/not exists/);
            done();
        });
        it('connects another zmq socket.', (done) => {
            var aPort = new IPT.InPort('in');
            var aSock = zmq.socket('push');
            aSock.bindSync('ipc:///tmp/testsock');
            setTimeout(() => aSock.close(), 5);
            expect(() => aPort.connect('ipc:///tmp/testsock'))
                .to.not.throw(/... not exists/);
            done();
        });
    });
});
