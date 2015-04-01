require! nconf

nconf
  .argv!
  .env!
  .defaults do 
    RUNTIME_SOCKETS_DIR: '/tmp/iclang/sockets'

exports.conf = nconf    