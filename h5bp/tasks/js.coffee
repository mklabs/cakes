
fs              = require 'fs'
path            = require 'path'
{spawn, exec}   = require 'child_process'
uglify          = require 'uglify-js'

helper = require './util/helper'

base = process.cwd()

# ## JS tasks
# These tasks are related to JS optimizations, mainly concat, `@import`  and minification 
# (using [uglify-js](https://github.com/mishoo/UglifyJS#readme)

# ### js.main.concat
#
# Concatenates the JS files in dir.js. depends on mkdirs
task 'js.main.concat', 'Concatenates the JS files in dir.js', (options, em) ->

  invoke 'mkdirs'

  concat = (output) ->
    output = new Buffer output.join('\n\n')
    fs.writeFile path.join(base, "#{dir.intermediate}", "#{dir.js.main}", 'script-concat.js'), output, (err) ->
      return error err if err
      em.emit 'log', 'script-concat.js just concat...'.grey
      em.emit 'end'

  handle = (files) ->
    em.emit 'log', 'Concatenating Main JS scripts...'

    scripts = file.root.script.split(' ').map (s) ->
      return "#{dir.js.main}/#{s}"

    helper.fileset "#{dir.js.main}/plugins.js " + scripts.join(' '), '', (err, files) ->
      output = []

      return em.emit 'end' unless files.length

      remaining = files.length
      for file in files then do (file) ->
        output.push fs.readFileSync(file)
        concat(output) if --remaining is 0 


  gem.once 'end:mkdirs', handle

# ### js.mylibs.concat
#
# Concatenates the JS files in dir.js.mylibs. depends on mkdirs
#
task 'js.mylibs.concat', 'Concatenates the JS files in dir.js.mylibs', (options, em) ->

  invoke 'mkdirs'

  concat = (output) ->
    output = new Buffer output.join('\n\n')
    fs.writeFile path.join(base, "#{dir.intermediate}", "#{dir.js.mylibs}", 'mylibs-concat.js'), output, (err) ->
      return error err if err
      em.emit 'log', 'mylibs-concat.js just concat...'
      em.emit 'end', true

  gem.once 'end:mkdirs', (files) ->
    em.emit 'log', "Concatenating JS libraries in #{dir.js.mylibs}"
    process.chdir path.join(base, "#{dir.intermediate}")

    # don't exit when no mylibs/ folder
    return em.emit 'end' unless path.existsSync "#{dir.js.mylibs}"


    helper.fileset "#{dir.js.mylibs}/**/*.js", "#{file.default.js.bypass}", (err, files) ->
      return error err if err
      output = []
      return concat(output) unless files.length

      remaining = files.length
      for file in files then do(file) ->
        output.push fs.readFileSync(file)
        concat(output) if --remaining is 0

# ### js.scripts.concat
#
# Concatenating library file with main script file
#
# Calculates an md5 checksum, prefix the script name, and copy over to `#{dir.publish}/#{dir.js}/`
#
#     publish/js/e816baa.scripts-concat.min.js
#
task 'js.scripts.concat', 'Concatenating library file with main script file', (options, em) ->

  # the scripts holders used in htmlclean
  scripts = {}

  concat = (source) ->
    concat.remaining = concat.remaining or= 0
    concat.remaining++

    return ->
      return if --concat.remaining
      helper.fileset "#{base}/#{dir.intermediate}/#{dir.js.main}/**-concat.js", (err, files) ->
        return error err if err

        em.emit 'log', 'Concatenating library file with main script file'

        return em.emit 'end' unless files.length

        helper.concat files, (err, buffers) ->
          return error err if err

          em.emit 'log', "Writing to #{dir.intermediate}/#{dir.js.main}/scripts-concat.min.js"

          filename = "scripts-concat.min.js"
          from = "#{dir.intermediate}/#{dir.js.main}/#{filename}"
          output = buffers.map (buffer) ->
            return buffer.toString()

          fs.writeFile path.join(base, from), output.join('\n\n'), (err) ->
            return error err if err
            em.emit 'log', "File ✔ #{from}"

            em.emit 'log', 'Calculating checksum...'


            helper.checksum path.join(base,from), (err, md5) ->
              return error err if err

              em.emit 'log', "✔ md5 is #{md5} for file #{from}"
              # now copy over the file to #{dir.js}/#{script.sha}.js
              md5 = md5.substring 0, hash.length
              to = "#{dir.intermediate}/#{dir.js.main}/#{md5}.#{filename}"

              # set the global script.js for future reference in usemin
              scripts.js = "#{md5}.#{filename}"

              em.emit 'log', "now copy over the file to #{to}"
              return helper.copy path.join(base, from), path.join(base, to), (err) ->
                return error err if err
                em.emit 'log', "✔ Copy done » #{to}"

                em.emit 'log', 'Minify the output now...'
                invoke 'js.all.minify'


  gem.on 'end:js.main.concat', concat('main')
  gem.on 'end:js.mylibs.concat', concat('mylibs')

  gem.on 'end:js.all.minify', em.emit.bind(em, 'end', scripts)

  invoke 'js.main.concat'
  invoke 'js.mylibs.concat'


# ### js.all.minify
#
# Minifies the scripts.js files in #{dir.intermediate}/#{dir.js}. depends on mkdirs
#
task 'js.all.minify', "Minifies the *-concat.js files in #{dir.intermediate}/#{dir.js.main}", (options, em) ->

  gem.once 'end:mkdirs', (result) ->
    em.emit 'log', 'Minifying scripts'.grey

    dirname = path.join dir.intermediate, dir.js.main
    process.chdir path.join(base, dirname)
    helper.fileset "**-concat.min.js", (err, files) ->
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

  invoke 'mkdirs'
