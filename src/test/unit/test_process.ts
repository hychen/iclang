/// <reference path="../bootstrap-test.d.ts" />
import P  = require('../../lib/process');

function newActComp() {
    return {
        friendlyName: 'ActComp',
        fn: () => false
    }
};

describe('class Process(name, ActComponent)', () => {
    describe('#start()', () => {
        var proc = new P.Process('Act Proc', newActComp());
        proc.start();
        it('does not create ports.', () => {
            expect(proc.ports).deep.equal({});
        });
        it('changes process status to running', () => {
            expect(proc.isRunning()).to.be.ok;
            proc.stop();
        });
    });
});
