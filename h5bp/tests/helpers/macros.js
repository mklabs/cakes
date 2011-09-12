var zombie = require('zombie'),
    colors = require('colors'),
    connect = require('connect'),
    path = require('path');

// ## macros
//
// and vows helpers. defines a few macros to help in tests
var macros = module.exports = {};

// **extendContext**: private module scope helper. copy over the properties from vows to context.
//
// borrowed to [hook.io macros](https://github.com/hookio/hook.io/blob/master/test/helpers/macros.js#170)
var extendContext = function extendContext (context, vows) {
  if (vows && vows.topic) {
    console.error('Cannot include topic at top-level of nested vows:'.red);
    process.exit(1);
  }

  Object.keys(vows).forEach(function (key) {
    context[key] = vows[key];
  });

  return context;
};


// **assertListen**: macro to start and listen to the port provided.
// Starts up a new connect server with very basic middleware setup,
// logger and static configured to serve the publish dir
macros.assertListen = function (port, root, vows) {
  var context = {
    topic: function () {
      var server = connect.createServer()
        .use(connect.static(path.join(__dirname, '../..', root)))
        .listen(port, this.callback.bind(this))
    }
  };

  return extendContext(context, vows);
};


// **assertZombie**: tell zombie to visit the page host:8080.
macros.assertZombie = function(host, port, vows) {
  var context = {
    topic: function() {
      zombie.visit('http://' + host + ':' + port, {runScripts: false}, this.callback.bind(this))
    }
  };

  return extendContext(context, vows);
};

