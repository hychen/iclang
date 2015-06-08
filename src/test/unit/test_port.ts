/** Module Port Unit Tests.
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
/// <reference path="../bootstrap-test.d.ts" />
import rimraf = require('rimraf');
import zmq = require('zmq');
import uuid = require('node-uuid');
import mochaTestCheck = require('mocha-testcheck');
import port  = require('../../lib/port');
import HELP = require('../helper');

describe('portAddr(id)', () => {
    beforeEach((done) => {
        HELP.initTestRuntimeEnv(done);
    });
    afterEach((done) => {
        HELP.deinitTestRuntimeEnv(done);
    });
    it('accepts a uuid v4 string and returns an ipc address.', (done) => {
        var addr = port.portAddr('ggg');
        expect(addr).to.match(/ipc:\/\//);
        expect(addr).to.match(/\.ic\/socket\/ggg/);
        done();
    });

    it('raises error if runtime directory not exists', (done) => {
        rimraf(global['TEST_RUNTIME_ROOT_DIR'], () => {
            expect(() => port.portAddr('yooo')).to.throw(/runtime directory.*not exists./);
            done();
        });
    });

    it('raises error if runtime socket directory not exists', (done) => {
        rimraf(global['TEST_RUNTIME_SOCKET_DIR'], () => {
            expect(() => port.portAddr('yooo')).to.throw(/runtime socket directory.*not exists./);
            done();
        });
    });
});

describe('OutPort', () => {
    beforeEach((done) => {
        HELP.initTestRuntimeEnv(done);
    });
    afterEach((done) => {
        HELP.deinitTestRuntimeEnv(done);
    });

    describe('#constructor(name)', () => {
        check.it('accepts a string ane returns a OutPort instance.)', {maxSize:10}, [gen.string], (name) => {
            var aPort = new port.OutPort(name);
            expect(aPort.name).to.eq(name);
            expect(aPort.id).to.be.ok;
        });
    });
});

describe('InPort', () => {
    beforeEach((done) => {
        HELP.initTestRuntimeEnv(done);
    });
    afterEach((done) => {
        HELP.deinitTestRuntimeEnv(done);
    });

    describe('#constructor(name)', () => {
        check.it('accepts a string ane returns a OutPort instance.)', {maxSize:10}, [gen.string], (name) => {
            var aPort = new port.InPort(name);
            expect(aPort.name).to.eq(name);
            expect(aPort.id).to.be.ok;
        });
    });

    describe('#connect(portAddr)', () => {
        it('thorws error if portAddr is not exists.', (done) => {
            var aPort = new port.InPort('in');
            expect(() => aPort.connect(uuid.v1())).to.throw(/not exists/);
            done();
        });

        it('connects another zmq socket.', (done) => {
            var aPort = new port.InPort('in');
            var aSock = zmq.socket('push');
            aSock.bindSync('ipc:///tmp/testsock');
            setTimeout(() => aSock.close(), 5);
            expect(() => aPort.connect('ipc:///tmp/testsock')).to.not.throw(/... not exists/);
            done();
        });
    });
});
