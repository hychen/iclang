/// <reference path="../../typings/lib/tsd.d.ts" />
/// <reference path="../../typings/test/tsd.d.ts" />

interface TestGlobal extends NodeJS.Global {
	expect: Chai.ExpectStatic;
};

/* Module Dependency
*/
import chai = require('chai');

/* Globals
*/
declare var global: TestGlobal;
var expect = chai.expect;
global.expect = expect;
