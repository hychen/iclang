require! 'fs'
validator = require 'is-my-json-valid'
should = require 'chai' .should!

ok = (s) ->
  validate s .should.be.ok
  
nok = (s, e) ->
  validate s .should.eq false, pprint validate.errors
  validate.errors.should.deep.eq e, pprint validate.errors

pprint = ->
  if it
    ["#{e.field}:#{e.message}" for e in it]
  else
    "expected some erros but none."

var schema, validate
describe 'HyperScript File', ->
  before (done) ->
    err, content <- fs.readFile 'schema/hyperscript-schema.json'
    schema := JSON.parse content
    validate := validator schema
    done!
  describe 'is a JSON file which follows the HyperScript JSON schema and', ->
    describe 'must has properties field that', -> ``it``
      test-data = ({name, desc, placeholder}={})->
        o = do
          processes: {}
          connections: []
        if placeholder? or (name? or desc?)
          o.properties = {}
        if name?
          o.properties.name = name
        if desc?
          o.properties.description = desc
        return o    
      .. 'properties field is required.', (done) ->
        s = test-data!
        nok s, [{field:'data.properties','message':'is required'}]
        done!          
      .. 'name and description are required.', (done) ->
        s = test-data name:'', desc:''
        ok s

        s = test-data name:''
        nok s, [{field:'data.properties','message':'referenced schema does not match'}]

        s = test-data desc:''
        nok s, [{field:'data.properties','message':'referenced schema does not match'}]
        done!
      .. 'name and description are string type.', (done) ->
        s = test-data name:1, desc:1
        nok s, [{field:'data.properties','message':'referenced schema does not match'}]

        s = test-data name:'', desc:1
        nok s, [{field:'data.properties','message':'referenced schema does not match'}]

        s = test-data name:1, desc:''
        nok s, [{field:'data.properties','message':'referenced schema does not match'}]        
        done!
    describe 'must has connections field that', -> ``it``
      .. 'indicates each connection between a source port and a destination port.', (done) ->
        base = do
          properties: {name:'', description:''}
          processes: {}
        script_conn_record_wrong_type = connections: ["bad_connection_record"] <<< base
        validate script_conn_record_wrong_type .should.be.not.ok
        done!
