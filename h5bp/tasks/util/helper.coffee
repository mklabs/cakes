
# `helpers` expose a basic wrapper around node-glob by isaacs and 
# findit by substack. Enable multiple pattern matching, and include
# exlude ability.


# External dependency
{EventEmitter}  = require 'events'
path            = require 'path'
fs              = require 'fs'
crypto          = require 'crypto'
child           = require 'child_process'
coffee          = require 'coffee-script'

# ## fileset
# expose filset module as helper method
exports.fileset = require 'fileset'

# ## extend
# Extend a source object with the properties of another object (shallow copy).
exports.extend = extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

# ### error() handler
#
#     return error err if err
#     return error new Error(':((') if err
exports.error = error = (err) ->
  console.error '  ✗ '.red + (err.message || err).red
  console.trace err
  process.exit 1

# ## load
#
# Load a task file, written in js or cs, and evaluate its content
# in a new VM context. Meant to be used as a forEach helper.

exports.load = (dirname, log) ->

  return (file) ->
    script = fs.readFileSync path.join(dirname, 'tasks', file), 'utf8'
    # tasks may be written in pure JS or coffee. Takes care of coffee compile if needed.
    script = if /\.coffee$/.test(file) then coffee.compile script else script

    # load and compile
    log.silly "Import #{file}"
    run script, path.join(dirname, 'tasks', file)

# Borrowed to coffee-script: CoffeeScript way of loading and compiling, correctly
# setting `__filename`, `__dirname`, and relative `require()`.

#     https://github.com/jashkenas/coffee-script/blob/master/src/coffee-script.coffee#L54-75
exports.run = run = (code, filename) ->
  mainModule = require.main

  # Set the filename.
  mainModule.filename = fs.realpathSync filename

  # Clear the module cache.
  mainModule.moduleCache and= {}

  # Assign paths for node_modules loading
  if process.binding('natives').module
    {Module} = require 'module'
    mainModule.paths = Module._nodeModulePaths path.dirname filename

  # Compile.
  mainModule._compile code, mainModule.filename

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

  # assume file is the actual content if no callback is provided
  unless callback
    md5.update file
    return md5.digest 'hex'

  fs.createReadStream(file)
    .on('error', (err) -> callback err)
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


exports.spawn = (cmd, args, callback) ->
  stderr = []
  stdout = []
  ch = child.spawn(cmd, args)

  ch.stdout.pipe process.stdout, {end: false}
  ch.stderr.pipe process.stderr
  ch.stdout.on 'data', (data) -> stdout[stdout.length] = data
  ch.stderr.on 'data', (data) -> stderr[stderr.length] = data

  ch.on 'exit', (code) ->
    stdout = stdout.join '\n'
    stderr = stderr.join '\n'

    callback code, stdout, stderr if callback
    ch.emit 'end', code,  stdout, stderr

  return ch
