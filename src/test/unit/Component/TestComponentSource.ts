/** Component.ComponentSource Unit Tests.
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */

/// <reference path="../../bootstrap-test.d.ts" />
import CS  = require('../../../lib/Component/ComponentSource');

describe('function loadComponentSource()', () => {
    describe('loads a component source file in javascript format.', () => {
        it('returns a component source.', () => {
            var fpath = '../../../fixtures/components/source_component.js';
            var component = CS.loadComponentSource(fpath);
            expect(component.provideComponent).to.be.ok;
        });
    });
});
