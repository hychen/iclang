export definition = do
  friendlyName: 'Print'
  description: 'To print a string to STDIN'
  inputs: do
    in:
      description: 'A string or a text.'
  default-exit: 'success'
  exits: do
    success: 
      description: 'Done.'
    error:
      description: 'Unexpected error occurred.'

export function provide-component(options)
  definition.fn = (inputs, exits) ->
    console.log inputs.in
  return definition