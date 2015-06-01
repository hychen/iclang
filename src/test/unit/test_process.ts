/// <reference path="../bootstrap-test.d.ts" />
import fs = require('fs');
import mkdirp = require('mkdirp');
import rimraf = require('rimraf');
import P  = require('../../lib/process');

function newActComp(){
    return {
        friendlyName: 'ActComp',
        fn: () => false
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

describe('class Process(name, ActComponent)', () => {
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
    describe('#start()', () => {
        it('does not create ports.', () => {
            var proc = new P.Process('Act Proc', newActComp());
            proc.start();
            expect(proc.ports).deep.equal({});
            proc.stop();
        });
        it('changes process status to running', () => {
            var proc = new P.Process('Act Proc', newActComp());
            proc.start();
            expect(proc.isRunning()).to.be.ok;
            proc.stop();
        });
    });
    describe('#stop()', () => {
        it('changes process status to terminating', () => {
            var proc = new P.Process('Act Proc', newActComp());
            proc.start();
            proc.stop();
            expect(proc.isRunning()).to.be.not.ok;
            expect(proc.getStatus()).eq('terminating');
        });
    });
});

describe('class Process(name, SourceActComponent)', () => {
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
    describe('#start()', () => {
        it('create ports.', () => {
            var proc = new P.Process('SourceAct Proc', newSourceActComponent());
            proc.start();
            expect(proc.ports['success']);
            proc.stop();
        });
        it('changes process status to running', () => {
            var proc = new P.Process('SourceAct Proc', newSourceActComponent());
            proc.start();
            expect(proc.isRunning()).to.be.ok;
            proc.stop();
        });
    });
    describe('#stop()', () => {
        it('changes process status to terminating', () => {
            var proc = new P.Process('Act Proc', newSourceActComponent());
            proc.start();
            proc.stop();
            expect(proc.isRunning()).to.be.not.ok;
            expect(proc.getStatus()).eq('terminating');
        });
        it('close all ports.', (done) => {
            var proc = new P.Process('Act Proc', newSourceActComponent());
            proc.start();
            proc.stop();
            var sockaddr = proc.ports['success'].addr.replace('ipc://', '');
            setTimeout(() => {
                expect(fs.existsSync(sockaddr)).to.not.be.ok;
                done(); }, 0.0001);
        });
    });
});


