cake(1) -- cake h5bp build script
=================================

## SYNOPSIS

    cake [options] <task>

## DESCRIPTION

**Cake, and Cakefiles**: quoting http://jashkenas.github.com/coffee-script/#cake

CoffeeScript includes a (very) simple build system similar to Make and
Rake. Naturally, it's called Cake, and is used for the tasks that build
and test the CoffeeScript language itself. Tasks are defined in a file
named Cakefile, and can be invoked by running cake [task] from within
the directory. To print a list of all the tasks and options, just type
cake.

Task definitions are written in CoffeeScript, so you can put arbitrary
code in your Cakefile. Define a task with a name, a long description,
and the function to invoke when the task is run. If your task takes a
command-line option, you can define the option with short and long
flags, and it will be made available in the options object.

Run `cake` to get a list of available commands. Run `cake -h <topic>
help` to show the appropriate documentation page.

## INTRODUCTION

You probably have this cake script to run a build process. There's a
bunch of tasks defined, but you'll probably want to run the main one:
build.

## LOGS

The cake script uses [Winston](https://github.com/indexzero/winston) to
easily manage logging statements used during the overall build process.
Log levels can be setup via cli options to only log messages with level
higher than the supplied `loglevel` option.

Available log levels are, from lowest to highest:

* silly
* input
* verbose
* prompt
* info
* data
* help
* warn
* debug
* error
* and silent

The default loglevel is set to `input`. If you want a build to be run
with a different log level, simply run the following:

    cake -l info <task>
    cake --loglevel silly <task>

Log levels can be provided with the short (`-l`) or long (`loglevel`) option format.

## CONFIGURATION

It may evolve to something a bit different but the configuration is now
managed using the `conf/default.coffee` file. It basically matches the
default properties file of the h5bp ant build script.

see `cake -h configuration help` for more informations.

## TASKS

Tasks can be written in CoffeeScript or pure JavaScript. The main
Cakefile includes a simple loading mechanism (relying on the
[vm](http://nodejs.org/docs/v0.5.10/api/vm.html) module, which
automatically loads the tasks files under tasks/ folder.

Creating/Removing tasks is simply a matter of creating new tasks files in the tasks/ folder. Tasks files are written very much the same way as the main Cakefile, simply define a task with:

* a name
* a long description
* and a function to be called when the task is run

## CAKE++

quoting the CoffeeScript website:

Cake tasks are a minimal way to expose your CoffeeScript functions to
the command line, so don't expect any fanciness built-in. If you need
dependencies, or async callbacks, it's best to put them in your code
itself — not the cake task.

Indeed, with complex scenarios, where a lot of tasks are involved, with
potential async code and probably tasks dependency with each other, we
need a way to ensure a given tasks is run only when the list of its
dependencies are done.

This is done using a modified version of cake's task function, where a
second parameter is avaible: a task-scopped event emitter.

Basically, tasks notify the build system they're done by emitting a `end` event,
with optionnal arguments other tasks may consume.

*more docs to come soon on this subject*

It's expected to change a little bit, with a more convenient api to work
with.

### Tasks dependencies

A tasks may invoke another tasks, and so forth express their dependencies
by using the `invoke` method Cake provides.

A given tasks can only be runned once, any tasks that tries to invoke a
task which was already run previously will do basically nothing, and
just ensure the `end` event is emitted.

A task that relies on others should wrap its main code using the `gem`
variable (automatically made available by the tasks loading) which
stands for Global EventEmitter. It works with the tasks scopped event
emitter and will emit a special event tasks could listen to. This event
emitted by the `gem` will take the form of `end:taskname`.

## DIRECTORIES

In particular, the cake build folder has the following directories:

* conf: configuration folders, includes default.coffee
* docs: the docs for the build script, markdown format.
* tasks: where the Cakefile lookup tasks to load
* tests: the vows test suite, ensuring everything works fine. `npm test` to run them.


## SEE ALSO

* cake -h build help
* cake -h createproject help
* cake -h css help
* cake -h docs help
* cake -h help help
* cake -h html help
* cake -h img help
* cake -h js help
* cake -h test help
