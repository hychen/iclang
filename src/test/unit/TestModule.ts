/** Module Module Unit Tests.
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
/// <reference path="../bootstrap-test.d.ts" />
import HELP = require('../Helper');
import MOD  = require('../../lib/module');

describe('loadModule()', () => {
    it('loads commonjs module.', (done) => {
        var mod = MOD.loadModule(HELP.fixturePath('modules/module_basic/'));
        expect(mod.components.component_a.provideComponent).to.be.ok;
        expect(mod.meta.language).to.eq('javascript');
        expect(mod.meta.components).to.deep.equal([
            'components/component_a.js',
            'components/component_b.js'
        ]);
        done();
    });
    it('throws error if any component defined in meta inot exists.', () => {
        var e = expect(() => {
            MOD.loadModule(
                HELP.fixturePath('modules/module_invalid_component_path/'))
            });
        e.to.throw(Error);
    })
    it('throws error if the directory not exists.', () => {
        expect(() => MOD.loadModule('a')).to.throw(Error);
    });
});
