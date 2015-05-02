require! path
require 'chai' .should!
global.expect = require 'chai' .expect
global.ic = require '../'

global.TEST_RUNTIME_DIR = path.join __dirname, 'fixtures', '.ic'

process.env.RUNTIME_DIR = global.TEST_RUNTIME_DIR
