
fs              = require 'fs'
path            = require 'path'
{spawn}         = require 'child_process'
{Ronn}          = require 'ronn'

# ## cake help
#
# This file is a special task file which uses [ronnjs](https://github.com/kapouer/ronnjs) to
# automatically generate manpage from the source file. It will basically output the comments,
# originally done to be docco compliant, using `man`. The source files are parsed and their
# markdown content is runned through ronnjs, then exeucted through the `man` executable.
#

# ### Usage
#
# Run `cake help` to display the default help message.
#
# Run `cake -h [task] help` or `cake --help [task] help` to display the man generated page for 
# the `[task]`, where [task] is one of the following:
#
# *   build
# *   createproject
# *   css
# *   docs
# *   help
# *   html
# *   img
# *   js
# *   lint
#
# Run `cake -h [unknown] help` where unkwown is anything but the valid task listed above. This will
# display the generated man for the Cakefile.
#

manfront = [
  "cake-:page(1) -- documentation for :page",
  "==========================================================================================================",
  "",
  ""
].join('\n')

task 'help', 'Output documentation for the cake task (cake -h [task] help), generated from source', (options, em) ->
  target = options.help || 'help'

  em.emit 'log', "Help #{target}"
  filepath = path.join __dirname, "#{target}.coffee"
  exists = path.existsSync filepath
  if not exists
    filepath = path.join __dirname, '../Cakefile'
    target = 'Cakefile'

  man parse(fs.readFileSync(filepath, 'utf8')), target, options, (code) ->
    em.emit 'end'
    process.exit code

handleFront = (input, page, options) ->
  front = manfront
  if page is 'Cakefile'
    front += "### Warn: #{options.help} is not a valid task, viewing the index (generated from Cakefile )"
  front.replace(/:page/g, page) + input

man = (output, target, options, callback) ->
  ronn = new Ronn(handleFront(output, target, options))
  stdio = process.binding 'stdio'
  manpath = path.join __dirname, '.man.swp'
  fs.writeFileSync manpath, ronn.roff()
  ch = spawn 'man', [manpath],
    customFds: [stdio.stdinFD, stdio.stdoutFD, stdio.stderrFD]

  ch.on 'exit', callback

getTasks = () ->
  fs.readdirSync(__dirname)
    .filter((file) -> fs.statSync(path.join(__dirname, file)).isFile() && /\.coffee$/.test(file) )
    .map((file) -> '* ' + file.replace(/\.coffee$/, ''))

matcher = /^\s*#\s?/
parse = (code) ->
  lines    = code.split '\n'
  sections = []
  save = (docs) ->
    sections.push docs

  for line in lines
    save line.replace(matcher, '') + '\n' if line.match matcher

  sections.join('\n')

