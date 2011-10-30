
var exec = require('child_process').exec,
path = require('path'),
fs = require('fs');

task('gh-pages.init', 'Create configuration file', function(options, em) {

  var defaults = {
    readme: 'README'
  };


  em.emit('data', defaults);

  var pkgpath = find(module, 'package.json'),
  pkg = JSON.parse(fs.readFileSync(pkgpath, 'utf8'));

  em.emit('log', 'Found a package.json at ', pkgpath);
  em.emit('data', pkg);

  console.log(pkg.directories);
  var dirs = pkg.directories  = pkg.directories || {};
  // http://npmjs.org/doc/json.html#directories
  dirs.lib = dirs.lib || '';
  dirs.bin = dirs.bin || ''; 
  dirs.man = dirs.man || '';
  dirs.doc = dirs.doc || '';
  dirs.example = dirs.example || '';

  ['dependencies', 'devDependencies', 'scripts', 'engines'].forEach(function(key) {
    delete pkg[key];
  });

  em.emit('data', pkg);

  em.emit('end', pkg);
});


task('gh-pages', 'Set up a gh-pages branch.', function(options, em) {
  em.emit('log', 'Setting up a gh-pages branch');

  gem.on('end:gh-pages.init', function(data) {

    console.log(data);
    var commands = [
      'git symbolic-ref HEAD refs/heads/gh-pages'
    ].join('&&');

    exec(commands, function(err, stdout) {
      if(err) return em.emit('warn', err);
      em.emit('log', 'Done.');
      em.emit('silly', stdout);
      em.emit('end');
    });

  });

  invoke('gh-pages.init');

});

task('gh-pages.blank', function(options, em) {

  var commands = [
    'git symbolic-ref HEAD refs/heads/gh-pages',
    'rm .git/index',
    'git clean -fdx',
    'echo "My GitHub Page" > index.html',
    'git add .',
    'git commit -a -m "First pages commit"'
    // 'git push origin gh-pages'
  ].join('&&');

  exec(commands, function(err, stdout) {
    if(err) return em.emit('error', err);
    em.emit('log', 'Done.');
    em.emit('silly', stdout);
    em.emit('end');
  });
});


//
// ### find (dir)
// pmodule: Parent module to read from.
// name: filename to look for.
// Searches up the directory tree from `dir` until it finds the specified filename.
//
function find(pmodule, name, dir) {
  var dir = path.dirname(dir || pmodule.filename);

  var files = fs.readdirSync(dir);

  if (~files.indexOf(name)) {
    return path.join(dir, name);
  }

  if (dir === '/') {
    throw new Error('Could not find ' + name + ' up from: ' + dir);
  } else if (!dir || dir === '.') {
    throw new Error('Cannot find ' + name + 'from unspecified directory');
  }

  return find(pmodule, name, dir);
};


