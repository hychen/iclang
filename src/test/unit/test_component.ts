/** Module Component
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
/// <reference path="../bootstrap-test.d.ts" />
import C  = require('../../lib/component');

describe('Module Component', () => {
    describe('function loadComponent()', () => {
        describe('loads a component source file in javascript format.', () => {
            it('returns a component.', () => {
                var fpath = '/Users/hychen/github/iclang/test/fixtures/components/source_component.js';
                var component = C.loadComponent(fpath);
                expect(component.friendlyName).to.eq('simplesrc');
            });
        });
    });
});
