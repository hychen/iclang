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

err-ref-nmatch = ->
  [{field: it,'message':'referenced schema does not match'}]

var schema, validate
describe 'HyperScript File', ->
  before (done) ->
    err, content <- fs.readFile 'schema/hyperscript-schema.json'
    schema := JSON.parse content
    validate := validator schema
    done!
  describe 'is a JSON file which follows the HyperScript JSON schema and', ->
    describe 'must has properties field that', -> ``it``
      err = err-ref-nmatch 'data.properties'    
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
        nok s, err

        s = test-data desc:''
        nok s, err
        done!
      .. 'name and description are string type.', (done) ->
        s = test-data name:1, desc:1
        nok s, err

        s = test-data name:'', desc:1
        nok s, err

        s = test-data name:1, desc:''
        nok s, err
        done!
    describe 'must has connections field that', -> ``it``
      err = err-ref-nmatch 'data.connections'
      test-script = (conn) ->
        properties:
          name: ''
          description: ''
        processes:{}
        connections: conn
      test-conn = (src, dest) ->
        o = {}
        if src?
          o.src = src
        if dest?
          o.dest = dest
        return [o]
      test-port = ({process,port}={}) ->
        o = {}
        if process?
          o.process = process
        if port?
          o.port = port
        return o
      .. 'connection field is required but the value can be a empty connection record list',  (done) ->
        ok test-script []
        s = test-script ['wrong-type']
        nok s, err
        done!
      describe 'could have port to port connections', -> ``it``      
        .. 'each connection includes a source port and destination port.', (done) ->        
          bad-port = test-port process:1, port:1
          src-port = test-port process:'processA', port:'out'
          dest-port = test-port process: 'processB', port: 'in'
          s = test-script test-conn src-port, dest-port
          ok s

          s = test-script test-conn null, null
          nok s, err

          s = test-script test-conn bad-port, dest-port
          nok s, err

          s = test-script test-conn src-port, bad-port
          nok s, err

          s = test-script test-conn bad-port, bad-port
          nok s, err
          done!      
