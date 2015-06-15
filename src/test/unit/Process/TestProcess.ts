/** Module Process Unit Tests.
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
/// <reference path="../../bootstrap-test.d.ts" />
import fs = require('fs');
import zmq = require('zmq');
import HELP = require('../../Helper');
import P  = require('../../../lib/Process/Process');
import PSCM  = require('../../../lib/Process/Common');

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

describe('class Process(name, ActComponent)', () => {
    beforeEach((done) => {
        HELP.initTestRuntimeEnv(done);
    });
    afterEach((done) => {
        HELP.deinitTestRuntimeEnv(done);
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
            expect(proc.getStatus()).eq(PSCM.ProcessStatus.terminating);
        });
    });
    describe('#connect()', () =>{
        it('throws error', () => {
            var aProc = new P.Process('Act Proc', newActComp());
            aProc.start();
            expect(() => aProc.connect('anyport', 'other address')).throw(
                /source port anyport not exists/
                );
        });
    });
    describe('#fireToken()', () => {
        it('invokes component function', () => {
            var proc = new P.Process('Act Proc', newActComp());
            proc.start();
            expect(proc.fireToken({}, {})).to.be.ok;
            proc.stop();
        });
    });
});

describe('class Process(name, SourceActComponent)', () => {
    beforeEach((done) => {
        HELP.initTestRuntimeEnv(done);
    });
    afterEach((done) => {
        HELP.deinitTestRuntimeEnv(done);
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
            expect(proc.getStatus()).eq(PSCM.ProcessStatus.terminating);
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
    describe('#connect()', () =>{
        it('throws error', () => {
            var aProc = new P.Process('Act Proc', newSourceActComponent());
            aProc.start();
            expect(() => aProc.connect('success', 'other address')).throw(
                /source port success is not a InPort./
                );
        });
    });
    describe('#inquery(P.ProcessInquery.OutPortAddr, any)', () => {
        it('thorws error if out port not exists.', () => {
            var aProc = new P.Process('Src Act Proc', newSourceActComponent());
            aProc.start();
            expect(()=>aProc.inquery(PSCM.ProcessInquery.OutPortAddr, 'oo')).throw(
                    /Port oo not exists./
            );
            aProc.stop();
        });
        it('returns a address of a OutPort.', () => {
            var aProc = new P.Process('Src Act Proc', newSourceActComponent());
            aProc.start();
            var addr = aProc.inquery(PSCM.ProcessInquery.OutPortAddr, 'success');
            expect(addr).match(/ipc:\/\//);
            aProc.stop();
        });
    });
    describe('#fireToken()', () => {
        it('invokes component function', (done) => {
            var proc = new P.Process('Act Proc', newSourceActComponent());
            proc.start();
            var mydone = (result) => {
                expect(result).to.eq(1);
                proc.stop();
                done();
            }
            proc.fireToken({}, {success: mydone});
        });
        it('thorws error if exit callback signatures are not matched.', (done) => {
            var proc = new P.Process('Act Proc', newSourceActComponent());
            proc.start();
            expect(() => proc.fireToken({}, {})).to.throw(
                'the exit callbacks does not contain success callback.');
            proc.stop();
            done();
        });
    });
    describe('#fireStream()', () => {
        it('send data to attached ports.', (done) => {
            var proc = new P.Process('Act Proc', newSourceActComponent());
            proc.start();
            var aSock = zmq.socket('pull');
            aSock.on('message', (data) => {
                expect(data.toString()).to.be.eq('1');
                proc.stop();
                done();
            })
            aSock.connect(proc.ports['success'].addr);
            proc.run();
        });
    });
});

describe('class Process(name, DestinationActComponent)', () => {
    beforeEach((done) => {
        HELP.initTestRuntimeEnv(done);
    });
    afterEach((done) => {
        HELP.deinitTestRuntimeEnv(done);
    });
    describe('#start()', () => {
        it('does not create ports.', () => {
            var proc = new P.Process('Dest Act Proc', newDestActComponent());
            proc.start();
            expect(proc.ports).not.deep.equal({});
            proc.stop();
        });
        it('changes process status to running', () => {
            var proc = new P.Process('Dest Act Proc', newDestActComponent());
            proc.start();
            expect(proc.isRunning()).to.be.ok;
            proc.stop();
        });
    });
    describe('#stop()', () => {
        it('changes process status to terminating', () => {
            var proc = new P.Process('Dest Act Proc', newDestActComponent());
            proc.start();
            proc.stop();
            expect(proc.isRunning()).to.be.not.ok;
            expect(proc.getStatus()).eq(PSCM.ProcessStatus.terminating);
        });
    });
    describe('#connect()', () =>{
        it('throws error if target address not exists.', () => {
            var aProc = new P.Process('Act Proc', newDestActComponent());
            aProc.start();
            expect(() => aProc.connect('in', 'other address')).throw(
                /other addressnot exists./
                );
        });
    });
    describe('#inquery(P.ProcessInquery.OutPortAddr, any)', () => {
        it('thorws error if out port not exists.', () => {
            var aProc = new P.Process('Dest Act Proc', newDestActComponent());
            aProc.start();
            expect(()=>aProc.inquery(PSCM.ProcessInquery.OutPortAddr, 'oo')).throw(
                    /Port oo not exists./
            );
            aProc.stop();
        });
        it('thorws error if the port is not a OutPort.', () => {
            var aProc = new P.Process('Dest Act Proc', newDestActComponent());
            aProc.start();
            expect(()=>aProc.inquery(PSCM.ProcessInquery.OutPortAddr, 'in')).throw(
                    /Port in is not an OutPort./
            );
            aProc.stop();
        });
    });
    describe('#fireToken()', () => {
        it('invokes component function', () => {
            var proc = new P.Process('Dest Act Proc', newDestActComponent());
            proc.start();
            expect(proc.fireToken({in:1}, {})).to.eq(2);
            proc.stop();
        });
    });
    describe('#fireStream()', () => {
        it('invokes component function.', (done) => {
            var mydone = (res) => {
                expect(res).to.eq(2);
                done();
            }
            var aProc = new P.Process('Dest Act Proc', newDestActComponent(mydone));
            aProc.start();
            var aSock = zmq.socket('push');
            var sockaddr = 'ipc:///tmp/testdata3';
            aSock.bindSync(sockaddr);
            aProc.ports['in'].connect(sockaddr);
            aSock.send('1');
            setTimeout(() => {
                aSock.close();
                aProc.stop();
            }, 0.05);
        });
    });
});
