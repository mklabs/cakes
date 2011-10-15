var path = require('path');
var fs   = require('fs');
var lib  = path.join(path.dirname(fs.realpathSync(__filename)), '../lib');

// Use this script while node-inspector is running.
//
// Usage:
//
//    node cakedebug.js --debug [task]
//
// Set a `debugger` statement and make sure to reload node-inspector
// whitin the delay below. This will allow you to debug the script,
// pretty neat.
//

var delay = 5000;
console.log('\nHurry up, ', delay / 1000, ' seconds to debug out.');

setTimeout(function() {
  require('coffee-script/lib/cake').run();
}, delay);

