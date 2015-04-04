# my-sum
#
# A normal function.
#
# ```
# mysum(
#  {
#    'list': [1,2,3,4]
#  }, 
#  {
#    success: function(outputs){
#      console.log(outputs.out);
#    }
#  }
# ```
export function my-sum(inputs, exists)
  result = 0
  if not inputs.list.length == 0
    exists.emptyList!
  else
    for let i in inputs.list
      result  += i
    exists.success {out:result}

# Component Default Function
#
# The definition format is compatible with Node Machine machine specification.
# which means you can use the component as a Node Machine in your javascript.
#
# ```
# Fixture.my-sum({
#   list:[1,2,3,4]
# }).exec({
#   success: function(results){
#     console.log(results.out}});
#   }
# });
# ```
export definition = do
  friendlyName: 'Sum up a list'
  description: 'get the sum of list'
  inputs: do
    list:
      description: 'list'
      example: '[1,2,3,4]'
  outputs: do
    out:
      description: 'returned tagged values'
  default-exit: 'success'
  exits: do
    emptyList:
      description: 'empty list.'
    success:
      example: '{out:10}'
      description: 'Returns the sum nummber'
    error:
      description: 'Unexpected error occurred.'
  fn: my-sum

# Component Provider
#
# A function gnerates a configured component definition will be loaded 
# and initialize a process to perform my-sum function.
#
# ```
# comp = new Component 'mysum'
# mysum = new Process comp
# # connect out port of mysum process to in port of print2console 
# # process.
# connect mysum, 'out', print2console, 'in'
# ```
export function provide-component(options)
  return definition
