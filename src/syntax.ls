require! fs
validator = require 'is-my-json-valid'

export function syntax-validator(_type)
  throw "type argument is not a string" unless typeof _type is 'string'
  schema-fname = "#{_type.toLowerCase!}-schema.json"
  schema-root = 'schema'
  schema-path = "#{schema-root}/#{schema-fname}"

  content = fs.readFileSync schema-path
  schema = JSON.parse content
  validator schema
