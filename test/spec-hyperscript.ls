require! 'fs'
validator = require 'is-my-json-valid'
should = require 'chai' .should!

var schema, validate
describe 'HyperScript File', ->
  before (done) ->
    err, content <- fs.readFile 'schema/hyperscript-schema.json'
    schema := JSON.parse content
    validate := validator schema
    done!
  describe 'is a JSON file which follows the HyperScript JSON schema and', ->
    describe 'must has properties field that', -> ``it``
      .. 'indicates name and description of the hyperscript.', (done) ->
        valid_script = do
          properties: do
            name: "script-name"
            description: "script-desc"
          processes: {}
          connections: []
          inports: []
          exports: []
        validate valid_script .should.be.ok

        script_missing_properties = do
          processes: {}
          connections: []
          inports: []
          exports: []
        validate script_missing_properties .should.not.be.ok        
        done!
