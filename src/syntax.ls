## Module Syntax
#
# Description of `Syntax`
require! fs
require! path
validator = require 'is-my-json-valid'

# --------------------------------------------
# Public Functions
# --------------------------------------------

# Takes a type name and returns a type validator
#
# @param String _type - The type
# @raise Error - When type is not a string
# @raise Error - When type is not supported
# @return Object - A validator of `is-my-json-valid` module.
export function syntax-validator(_type)
  throw "type argument is not a string" unless typeof _type is 'string'
  schema-fname = "#{_type.toLowerCase!}-schema.json"
  schema-root = path.join __dirname, '../', 'schema'
  schema-path = "#{schema-root}/#{schema-fname}"
  if fs.existsSync schema-path
    content = fs.readFileSync schema-path
    schema = JSON.parse content
    validator schema
  else
    throw new Error "Invalid Type #{_type}"
