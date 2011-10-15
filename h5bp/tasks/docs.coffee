
{spawn, exec}   = require 'child_process'

# ### docs
# Generates the source documentation of this cake script
#
# added as a conveniency
task 'docs', 'Generates the source documentation of this cake script', (options, em) ->

  commands = [
    "rm -rf documentation"
    "cp Cakefile Cakefile.coffee"
    "docco conf/*.coffee *.coffee tasks/*.coffee tasks/*.js"
    "cp -r docs documentation"
    "rm -rf docs Cakefile.coffee"
  ].join(' && ')

  exec commands, (err, stdout) ->
    return error err if err

    em.emit 'log', '\n  » ' + stdout.trim().split('\n').join('\n  » ')
    em.emit 'log', ' ✔ Documentation generated » docs/ → documentation/'
    em.emit 'end'