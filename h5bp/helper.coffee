
# `helpers` expose a basic wrapper around node-glob by isaacs and 
# findit by substack. Enable multiple pattern matching, and include
# exlude ability.


# External dependency
{EventEmitter}  = require 'events'
path            = require 'path'
fs              = require 'fs'
crypto          = require 'crypto'

# ## fileset
# expose filset module as helper method
exports.fileset = require 'fileset'


# ## concat
# ease the concatenation process by taking a list of absolute path, and returning
# an array of Buffers. There is no order management yet.
exports.concat = (files, callback) ->
  return callback new Error('concat: Files array is empty') unless files.length

  output = []
  remaining = files.length
  onFile = (err, body) ->
    return callback err if err
    output.push body
    callback null, output if --remaining is 0

  fs.readFile file, onFile for file in files

# ## checksum
# Simple checksum helper, takes an absolute path, open a fileStream,
# and generates back the according `md5` hash, `hex` encoded.
exports.checksum = (file, callback) ->
  md5 = crypto.createHash 'md5'
  fs.createReadStream(file)
    .on('error', -> callback err)
    .on('data', (data) -> md5.update data)
    .on('end', () -> callback null, md5.digest('hex'))



# ## copy
#
# Takes two path parameters: from and to, opens a ReadStream on from, a WriteStream on to,
# and pipes the ReadStream to the WriteStream. **files must exists**
#
exports.copy = (from, to, callback) ->
  fstream = fs.createReadStream(from)
  wstream = fs.createWriteStream(to)

  fstream.pipe wstream
  fstream
    .on('end', -> callback null )
    .on('error', (err) -> callback err)

