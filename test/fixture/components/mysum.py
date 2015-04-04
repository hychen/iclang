# my-sum
#
# A normal function.
#
# ```
# def mysum_success(outputs)
#   print(outputs)
#
# mysum(
#  {
#    'list': [1,2,3,4]
#  }, 
#  {
#    success: mysum_success
#  }
# ```
def my-sum(inputs, exists)
  result = 0
  if not inputs.list.length == 0
    exists.emptyList()
  else
    for let i in inputs.list
      result  += i
    exists.success({out:result})

# Component Default Function
#
# The definition format is compatible with Node Machine machine specification.
# which means you can use the component as a Node Machine in your javascript.
#
# ```
# Fixture.mysum({
#   list:[1,2,3,4]
# }).exec({
#   success: mysum_success
# });
# ```
definition = {
  friendlyName: 'Sum up a list',
  description: 'get the sum of list',
  inputs: {
    list: {
      description: 'list',
      example: '[1,2,3,4]'
    }
  },
  outputs: {
    out:{
      description: 'returned tagged values'
    }
  },
  default-exit: 'success',
  exits: {
    emptyList: {
      description: 'empty list.'
    },
    success: {
      example: '{out:10}',
      description: 'Returns the sum nummber'
    },
    error: {
      description: 'Unexpected error occurred.'
    }
  },
  fn: my-sum
}

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
# send list to mysum and print the result to console.
# mysum.ports.list.send [1,2,3,4]
# ```
def provide-component(options)
  return definition
