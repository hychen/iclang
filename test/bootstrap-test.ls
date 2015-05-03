require! path
require 'chai' .should!
global.expect = require 'chai' .expect
global.ic = require '../'

global.TEST_RUNTIME_DIR = path.join __dirname, 'fixtures', '.ic'
global.TEST_RUNTIME_SOCKET_DIR = path.join global.TEST_RUNTIME_DIR, 'socket'
process.env.RUNTIME_DIR = global.TEST_RUNTIME_DIR
