/// <reference path="bootstrap-test.d.ts" />

/* Module Dependency */
import chai = require('chai');

/* Globals */
global['expect'] = chai.expect;

import mochaTestCheck = require('mocha-testcheck');
mochaTestCheck.install();