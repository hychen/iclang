/** Component.Component Unit Tests.
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
/// <reference path="../../bootstrap-test.d.ts" />
import HELP = require('../../Helper');
import C  = require('../../../lib/Component/Component');

describe('function loadComponent()', () => {
    describe('loads a component source file in javascript format.', () => {
        it('returns a source component.', () => {
            var fpath = HELP.fixturePath('components/source_component.js');
            var component = C.loadComponent(fpath);
            expect(component.friendlyName).to.eq('simplesrc');
            expect(component['exits'].success).to.be.ok;
        });
        it('returns a pipe component.', () => {
            var fpath = HELP.fixturePath('components/pipe_component.js');
            var component = C.loadComponent(fpath);
            expect(component.friendlyName).to.eq('simplepipe');
            expect(component['inputs'].in).to.be.ok;
            expect(component['exits'].success).to.be.ok;
            component.fn({in:1}, {success: (res) => expect(res).to.eq(2) });
        });
        it('returns a destination component.', () => {
            var fpath = HELP.fixturePath('components/destination_component.js');
            var component = C.loadComponent(fpath);
            expect(component.friendlyName).to.eq('simpledest');
            expect(component['inputs'].in).to.be.ok;
        });
    });
});
