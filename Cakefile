
# `cake` is a simplified version of [Make](http://www.gnu.org/software/make/)
# ([Rake](http://rake.rubyforge.org/), [Jake](http://github.com/280north/jake))
# for CoffeeScript. You define tasks with names and descriptions in a Cakefile,
# and can call them from the command line, or invoke them from other tasks.
#
# Running `cake` with no arguments will print out a list of all the tasks in the
# current directory's Cakefile.

# External dependencies.
fs              = require 'fs'
path            = require 'path'
{spawn, exec}   = require 'child_process'
{EventEmitter}  = require 'events'
colors          = require('colors')
prompt          = require('prompt')
mkdirp          = require('mkdirp')
config          = require('./conf/default')
helper          = require('./helper')
uglify          = require 'uglify-js'

base = process.cwd()

# Extend a source object with the properties of another object (shallow copy).
extend = exports.extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

# ## configuration
repo = 
  h5bp: 'git://github.com/paulirish/html5-boilerplate.git'

# merge the local config with global object for this module, 
# so that interpolation works as expected (of course, config should not redefine global variable)
extend global, config

# the event emitter used along tasks to handle some asynchronous stuff, gem for global EventEmitter
gem = new EventEmitter

# ### task monkey-patch
#
# to provide a tasks-scopped EventEmitter which tasks could work with to enable some async stuff and task ordering
#
_task = global.task
task = (name, description, action) ->

  _task name, description, (options) -> 
    em = new EventEmitter
    gem.emit "start:#{@.name}", options

    em
      .on('error', (err) -> error err)
      .on('log', console.log.bind console, "#{name} » ".magenta)
      .on('start', (options) -> console.log name.magenta, description.grey)
      .on('end', (results) ->
        console.log "end:#{name}".cyan
        gem.emit "end:#{name}", results
      )

    action.call @, options, em


# error handler, usage:
#
#     return error err if err
#
#     return error new Error(':((') if err
error = (err) ->
  gem.emit 'error', err
  console.error '  ✗ '.red + err.message.red
  process.exit 1


# ### createproject
#
# Generate a new project from your HTML5 Boilerplate repo clone
#
# - by: Rick Waldron & Michael Cetrulo
# - cake edition by: Mickael Daniel
#
# The terminal will prompt with this message:
#
#     To create a new html5-boilerplate project, 
#     enter a new directory name:
#
# Type the name of the new project you are creating, ideally in lowercase letters,
# with no spaces - this will be the directory name that your new project lives in. 
# Press Enter to continue.
#
# If you attempt to create a directory that already exists, createproject.sh will warn you and stop running.
#
# If all goes smoothly, you will see the following messages:
#
#     Created Directory: [name]
#
#     [ A list of all the html5-boilerplate files being copied ]
#
#     Created Project: [name]
# Success! You now have a clean project to begin making the next HTML5 wunderkind demo!
# 

task 'createproject', 'a simple create project task', (options) ->

  src = path.join __dirname, repo.h5bp.split('/').reverse()[0].replace(/\.git/, '')

  exists = path.existsSync src

  commands = [
    if exists then "cd #{src}" else 'rm -rf html5-boilerplate'
    if exists then "git pull" else "git clone #{repo.h5bp}"
  ].join(' && ')
  gitcmd = if exists then 'pull' else 'clon'

  console.log 'createproject'.magenta, "#{gitcmd}ing #{repo.h5bp}...".grey
  exec commands, (err, stdout) ->
    return error err if err
    stdout = stdout.replace(/\n/gm, '')
    console.log "  ✔  #{stdout}".grey.bold

    console.log '  - To create a new html5-boilerplate project, enter a new directory name:'.blue

    prompt.message = "    ↩ ".bold
    prompt.delimiter = ''

    prompt.start()
    prompt.get ['directory'], (err, result) ->
      return error err if err
      return error new Error("please provide a directory name") unless result.directory
      dest = path.join(__dirname, result.directory)
      mkdirp dest, 0755, (err) ->
        return error err if err
        console.log "  ✔  Created Directory: #{dest}".grey.bold
        exec ["cd #{src}", "cp -vr css js img build test *.html *.xml *.txt *.png *.ico .htaccess #{dest}"].join(' && '), (err, stdout, stderr) ->
          return error stderr if err
          output = stdout.split(/\n/)

          output.forEach (line) -> console.log "    » #{line}".grey
          console.log "  ✔  Created Project: #{dest}".grey.bold


# ### intro 
#
# Output the intro message
#
task 'intro', 'Kindly inform the developer about the impending magic', (options, em) ->
  message = """

    ====================================================================
    Welcome to the ★ HTML5 Boilerplate Build Script! ★
     
    We're going to get your site all ship-shape and ready for prime time.
     
    This should take somewhere between 15 seconds and a few minutes,
    mostly depending on how many images we're going to compress.
     
    Feel free to come back or stay here and follow along.
    =====================================================================
  """

  em.emit 'log', message.grey
  em.emit 'end', message.grey

task 'clean', 'Wipe the previous build', (options, em) ->
  invoke 'intro'

  em.emit 'log', 'Cleaning up previous build directory...'.grey


  exec "rm -rf #{dir.intermediate} #{dir.publish}", (err, stdout, stderr) ->
    return error err if err

    em.emit 'end', stdout

# ### mkdirs
# Create the directory structure
#
# Copy the whole `dir.source` to both `dir.puslish` and `dir.intermediate`
#
task 'mkdirs', 'Create the directory structure', (options, em) ->

  invoke 'clean'

  gem.on 'end:clean', ->
    failmsg = "Your dir.publish folder is set to #{dir.publish} which could delete your entire site or worse. Change it in project.properties"
    dangerousPath = !!~['..', '.', '/', './', '../'].indexOf(dir.publish)
    return error new Error(failmsg) if dangerousPath

    process.chdir path.join(__dirname, "#{dir.source}")
    helper.fileset(".", [file.default.exclude, file.exclude].join(' '))
      .on('error', console.error.bind(console))
      .on('end', (files) ->
        em.emit 'log', "Copying #{files.length} files over to #{dir.intermediate} and #{dir.publish}".grey
        destinations = [dir.intermediate, dir.publish]
        remaining = files.length * destinations.length
        for to in destinations then do (to) ->
          for file in files then do(file) ->
            fragment = file.split '/'
            dirname = '/' + file.split('/')[1..-2].join('/')
            dirname = dirname.replace(dirname.split(__dirname)[1].split('/')[1..][0], to)
            filename = file.split('/')[-1..][0]

            mkdirp dirname, 0755, (err) ->
              return error err if err
              to = path.join(dirname, filename)
              exec "cp -v #{file} #{to}", (err, stdout, stderr) ->
                return error err if err
                em.emit 'end', 'done' if --remaining is 0
      )



# ### js.main.concat
#
# Concatenates the JS files in dir.js. depends on js.all.minify
task 'js.main.concat', 'Concatenates the JS files in dir.js', (options, em) ->
  concat = (output) ->
    output = new Buffer output.join('\n\n')
    fs.writeFile path.join(__dirname, "#{dir.intermediate}", "#{dir.js}", 'script-concat.js'), output, (err) ->
      return error err if err
      em.emit 'log', 'script-concat.js just concat...'.grey
      em.emit 'end', true

  handle = (files) ->
    em.emit 'log', 'Concatenating Main JS scripts...'

    process.chdir path.join(__dirname, dir.intermediate)
    helper.fileset "#{dir.js.main}/plugins.js #{dir.js.main}/#{file.root.script}", '', (err, files) ->
      output = []
      remaining = files.length
      for file in files then do (file) ->
        fs.readFile file, (err, body) ->
          return error err if err
          output.push body

          concat(output) if --remaining is 0 


  gem.once 'end:js.all.minify', handle

# ### js.mylibs.concat
#
# Concatenates the JS files in dir.js.mylibs. depends on js.all.minify
#
task 'js.mylibs.concat', 'Concatenates the JS files in dir.js.mylibs', (options, em) ->

  concat = (output) ->
    output = new Buffer output.join('\n\n')
    fs.writeFile path.join(__dirname, "#{dir.intermediate}", "#{dir.js.mylibs}", 'mylibs-concat.js'), output, (err) ->
      return error err if err
      em.emit 'log', 'mylibs-concat.js just concat...'.grey
      em.emit 'end', true

  gem.once 'end:js.all.minify', (files) ->
    em.emit 'log', "Concatenating JS libraries in #{dir.js.mylibs}".grey

    process.chdir path.join(__dirname, "#{dir.intermediate}")
    helper.fileset "#{dir.js.mylibs}/**/*.js", "#{file.default.js.bypass}", (err, files) ->
      return error err if err

      output = []
      remaining = files.length
      for file in files then do(file) ->
        fs.readFile file, (err, body) ->
          return error err if err
          output.push body
          concat(output) if --remaining is 0


# ### js.scripts.concat
#
# Concatenating library file with main script file
#
task 'js.scripts.concat', 'Concatenating library file with main script file', (options, em) ->
  # depends js.main.concat, js.mylibs.concat
  invoke 'js.all.minify'
  invoke 'js.main.concat'
  invoke 'js.mylibs.concat'

# ### js.mylibs.concat
#
# Minifies the scripts.js files in #{dir.intermediate}/#{dir.js}. depends on mkdirs
#
task 'js.all.minify', "Minifies the scripts.js files in #{dir.intermediate}/#{dir.js}", (options, em) ->
  invoke 'mkdirs'

  gem.on 'end:mkdirs', (result) ->
    em.emit 'log', 'Minifying scripts'.grey

    dirname = path.join dir.intermediate, dir.js
    process.chdir path.join(__dirname, dirname)
    helper.fileset "**.js", "**.min.js", (err, files) ->
      return error err if err

      remaining = files.length
      for file in files then do (file) ->
        fs.readFile file, (err, body) ->
          jsp = uglify.parser
          pro = uglify.uglify

          ast = jsp.parse body.toString()
          ast = pro.ast_mangle ast
          ast = pro.ast_squeeze ast
          code = new Buffer pro.gen_code(ast)

          fs.writeFile file, new Buffer(code), (err) ->
            return error err if err
            em.emit 'log', "Uglified #{file}".grey
            em.emit 'end', files if --remaining is 0


# ### usemin
# Replaces references to non-minified scripts
task 'usemin', 'Replaces references to non-minified scripts', (options) ->

# ### manifest
# Replaces references to non-minified scripts, depends js.script.concat
task 'manifest', 'copying a fresh file.manifest to dir.intermediate', (options) ->

# ### htmlclean
# Replaces references to non-minified scripts, depends usemin
task 'htmlclean', 'Run htmlcompressor on th HTML', (options) ->

# ### htmlbuildkit
# Replaces references to non-minified scripts, depends usemin
task 'htmlbuildkit', 'Run htmlcompressor on th HTML', (options) ->

# ### htmlcomplress
# Replaces references to non-minified scripts,  depends usemin
task 'htmlcompress', 'Run htmlcompressor on th HTML', (options) ->
