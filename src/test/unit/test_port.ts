/// <reference path="../bootstrap-test.d.ts" />
import port  = require('../../lib/port');
import mkdirp = require('mkdirp');
import rimraf = require('rimraf');

describe('portAddr(id)', () => {
    beforeEach((done) => {
        mkdirp(global['TEST_RUNTIME_ROOT_DIR'], () => {
            mkdirp(global['TEST_RUNTIME_SOCKET_DIR'], done);
        });
    });
    afterEach((done) => {
        rimraf(global['TEST_RUNTIME_ROOT_DIR'], () => {
            rimraf(global['TEST_RUNTIME_SOCKET_DIR'], done);
        });
    });

    it('accepts a uuid v4 string and returns an ipc address.', (done) => {
        var addr = port.portAddr('ggg');
        expect(addr).to.match(/ipc:\/\//);
        expect(addr).to.match(/\.ic\/socket\/ggg/);
        done();
    });

    it('raises error if runtime directory not exists', (done) => {
        rimraf(global['TEST_RUNTIME_ROOT_DIR'], () => {
            expect(() => port.portAddr('yooo')).to.throw('runtime directory not exists.');
            done();
        });
    });

    it('raises error if runtime socket directory not exists', (done) => {
        rimraf(global['TEST_RUNTIME_SOCKET_DIR'], () => {
            expect(() => port.portAddr('yooo')).to.throw('runtime socket directory not exists.');
            done();
        });
    });
});
