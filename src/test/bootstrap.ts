/** Test Bootstrap
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
/// <reference path="bootstrap-test.d.ts" />

/* Module Dependency */
import chai = require('chai');
import path = require('path');

/* Globals */
global['expect'] = chai.expect;

import mochaTestCheck = require('mocha-testcheck');
mochaTestCheck.install();

global['TEST_FIXTURE_ROOT_DIR'] = path.join(__dirname, 'fixtures');
global['TEST_RUNTIME_ROOT_DIR'] = path.join(global['TEST_FIXTURE_ROOT_DIR'], '.ic');
global['TEST_RUNTIME_LOG_DIR'] = path.join(global['TEST_RUNTIME_ROOT_DIR'], 'log');
global['TEST_RUNTIME_SOCKET_DIR'] = path.join(global['TEST_RUNTIME_ROOT_DIR'], 'socket');
process.env['RUNTIME_ROOT_DIR'] = global['TEST_RUNTIME_ROOT_DIR'];
process.env['RUNTIME_LOG_DIR'] = global['TEST_RUNTIME_LOG_DIR'];
