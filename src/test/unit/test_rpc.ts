/// <reference path="../bootstrap-test.d.ts" />
import mkdirp = require('mkdirp');
import rimraf = require('rimraf');
import RPC  = require('../../lib/rpc');
import PS  = require('../../lib/process');

function newActComp(){
    return {
        friendlyName: 'ActComp',
        fn: () => true
    }
};

function newSourceActComponent(){
    return {
        friendlyName: 'SourceActComp',
        exits: {
            success: {
                description: 'returns 1.'
            }
        },
        fn: (inputs, exits) => exits.success(1)
    }
}

function newDestActComponent(done?){
    return {
        friendlyName: 'DestActComp',
        inputs: {
            in: {
                description: 'an input value.'
            }
        },
        fn: (inputs) => {
            var res = inputs.in + 1;
            if(done){
                done(res);
            }else{
                return res;
            }
        }
    }
}

describe('Process RPC Callbacks', () => {
    beforeEach((done) => {
        mkdirp(global['TEST_RUNTIME_ROOT_DIR'], (err) => {
            if(err) throw err;
            mkdirp(global['TEST_RUNTIME_SOCKET_DIR'], done);
        });
    });
    afterEach((done) => {
        rimraf(global['TEST_RUNTIME_ROOT_DIR'], () => {
            rimraf(global['TEST_RUNTIME_SOCKET_DIR'], done);
        });
    });
    describe('rpcCallbackPingMethod()', () => {
        it('response `pong`.', (done) => {
            var process = new PS.Process('A', newActComp());
            var cb = RPC.rpcProcessPingMethod.bind(process);
            cb(null, (err, res, more) => {
                expect(res).to.eq('pong');
                done();
            });
        });
    });
    describe('rpcProcessConfigureMethod()', () => {
        it('changes process behavior.', (done) => {
            var process = new PS.Process('A', newActComp());
            var cb = RPC.rpcProcessConfigureMethod.bind(process);
            cb({}, null, (err, res, more) => {
                done();
            });
        });
    });
});
