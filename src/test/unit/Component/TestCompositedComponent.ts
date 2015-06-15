/** Component.ComponentSource Unit Tests.
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
/// <reference path="../../bootstrap-test.d.ts" />
import HELP = require('../../Helper');
import CTCC  = require('../../../lib/Component/CompositedComponent');

describe('function loadCompositedComponent()', () => {
    describe('loads a component source file in javascript format.', () => {
        it('replaces component relative path by absloute path.', (done) => {
            var fpath = HELP.fixturePath('programs/program_sequence.json');
            var component = CTCC.loadCompositedComponent(fpath);
            expect(component.import['source']).to.eq(
                HELP.fixturePath('components/source_component.js')
                );
            done();
        });
    });
});
