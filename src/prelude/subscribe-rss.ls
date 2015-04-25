export definition = do
  friendlyName: 'Subscribe a feed.'
  description: 'Subscribe a remote RSS/Atom/JSON feed and output of any items it reads.'
  options: do
    return-type: do
      description: 'emit article or articles.'
      default: 'item'
  inputs: do
    feed:
      description: 'A feed url.'
      example: 'http://rss.cnn.com/rss/cnn_latest.rss'
  outputs: do
    out:
      description: 'returned article(s)'
  default-exit: 'success'
  exits: do
    success: 
      description: 'New article(s) fetched.'
    error:
      description: 'Unexpected error occurred.'

export function provide-component(options)
  return-type = 'item' unless options.return-type?
	definition.fn = (inputs, exits) ->
    reader = new FeedSub inputs.feed
    reader.on 'error', ->
      exits.error it
    reader.on return-type, ->
      exits.success {out: it}
    reader.start!
  return definition