export definition = do
  friendlyName: 'Pulse.'
  description: 'To send a pulse every 10s'
  outputs: do
    out:
      description: 'return pulse'
  default-exit: 'success'
  exits: do
    success:
      description: 'New pluse token send.'
    error:
      description: 'Unexpected error occurred.'

export function provide-component(options)
  definition.fn = (inputs, exits) ->
    setInterval (->
      exits.success {out:1}
      ), 10
  return definition