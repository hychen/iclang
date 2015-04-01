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

test-script-from-proc = (n, proc) ->
  o = do
    properties:
      name: ''
      description: ''
    processes: {}
    connections: []
  o.processes[n] = proc
  return o

test-script-from-conn = (conn) ->
  properties:
    name: ''
    description: ''
  processes:{}
  connections: conn

test-script-from-properties = ({name, desc}={})->
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

test-script-from-inexports = ({inports,exports} = {}) ->
  o = test-script-from-conn []
  if inports?
    o.inports = inports
  if exports?
    o.exports = exports
  return o

test-proc = (c, opt) ->
  o = {}
  if c
    o.component = c
  if opt
    o.option = opt
  return o

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

test-inports = (n, p) ->
    [name:n, dest:p]

test-exports = (n, p) ->
    [name:n, src:p]

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
      .. 'properties field is required.', (done) ->
        s = test-script-from-properties!
        nok s, [{field:'data.properties','message':'is required'}]
        done!
      .. 'name and description are required.', (done) ->
        s = test-script-from-properties name:'', desc:''
        ok s

        s = test-script-from-properties name:''
        nok s, err

        s = test-script-from-properties desc:''
        nok s, err
        done!
      .. 'name and description are string type.', (done) ->
        s = test-script-from-properties name:1, desc:1
        nok s, err

        s = test-script-from-properties name:'', desc:1
        nok s, err

        s = test-script-from-properties  name:1, desc:''
        nok s, err
        done!
    describe 'must have processes field', -> ``it``
      err = err-ref-nmatch 'data.processes'
      .. 'each process record indicats each process belongs to which component.', (done) ->
        s = test-script-from-proc 'Process', test-proc 'repo/proj', {}
        ok s

        #@FIXME: the hyperscript validation does not handle this case.
        #s = test-script-from-proc {}, test-proc 'repo/proj', {}
        #nok s, err

        s = test-script-from-proc 'Process', test-proc 'repo/proj', {x:1,y:2}
        ok s

        s = test-script-from-proc 'Process', test-proc 'repo/proj', 1
        nok s, err

        s = test-script-from-proc 'Process', test-proc 1, {x:1, 2}
        nok s, err
                                                                        
        done!
    describe 'must have connections field that', -> ``it``
      err = err-ref-nmatch 'data.connections'
      .. 'connection field is required but the value can be a empty connection record list',  (done) ->
        ok test-script-from-conn []
        s = test-script-from-conn ['wrong-type']
        nok s, err
        done!
      describe 'could have port to port connections', -> ``it``
        .. 'each connection includes a source port and destination port.', (done) ->
          bad-port = test-port process:1, port:1
          src-port = test-port process:'processA', port:'out'
          dest-port = test-port process: 'processB', port: 'in'
          
          s = test-script-from-conn test-conn src-port, dest-port
          ok s

          s = test-script-from-conn test-conn null, null
          nok s, err

          s = test-script-from-conn test-conn bad-port, dest-port
          nok s, err

          s = test-script-from-conn test-conn src-port, bad-port
          nok s, err

          s = test-script-from-conn test-conn bad-port, bad-port
          nok s, err
          done!
    describe 'could have inports or exports field', -> ``it``
      err-in = err-ref-nmatch 'data.inports'
      err-exp = err-ref-nmatch 'data.exports'
      bad-process-port = test-port process:1, port:2
      process-port = test-port process:'processA', port:'out'        
      .. 'each inport has a name and destination process port.', (done) ->
        s = test-script-from-inexports inports: test-inports 'inport', process-port
        ok s

        s = test-script-from-inexports inports: test-inports 1, process-port
        nok s, err-in
        
        s = test-script-from-inexports inports: test-inports 'inport', bad-process-port
        nok s, err-in

        s = test-script-from-inexports inports: {}
        nok s, err-in
                
        done!
      .. 'each exports has a name and source process port.', (done) ->
        s = test-script-from-inexports exports: test-exports 'export', process-port
        ok s

        s = test-script-from-inexports exports: test-exports 1, process-port
        nok s, err-exp

        s = test-script-from-inexports exports: test-exports 'export', bad-process-port
        nok s, err-exp

        s = test-script-from-inexports exports: {}
        nok s, err-exp
        
        done!
