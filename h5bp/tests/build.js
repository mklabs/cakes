var zombie = require('zombie'),
    colors = require('colors'),
    assert = require('assert'),
    connect = require('connect'),
    path = require('path');
/*
var server = new HTTPServer({
  port: 8080,
  cache: 3600,
  root: 'h5bp/publish'
});


server.start();

process.on('SIGINT', function() {
  server.log('http-server stopped.'.red);
  return process.exit();
});
*/

var server = connect.createServer()
//  .use(connect.logger('dev'))
  .use(connect.logger(function(tokens, req, res) {
    var status = res.statusCode;

    status = status >= 500 ? 
      ('' + status).red :
      status >= 400 ? ('' + status).yellow :
      ('' + status).green;


    return [
      ('  >> ' +  req.method).magenta,
      req.originalUrl.grey,
      status,
      ('- ' + (+new Date - req._startTime) + 'ms').grey
    ].join(' ');
  }))
//  .use(connect.logger('tiny'))
  .use(connect.static(path.join(__dirname, '../publish')))
  .listen(8080);

// Load the page from localhost
console.log('  >> When hitting http://localhost:8080/"'.grey);

zombie.visit("http://localhost:8080/", function (err, browser, status) {
  if(err) return assert.fail(err.message);

  var $ = function qsa(selector) {
    return Array.prototype.slice.call(browser.querySelectorAll(selector));
  };

  var scripts = $('script[src]');

  assert.ok(scripts.length, 'should have some script with src attribute'.red.bold);
  assert.ok($('link[href]').length, 'should have some links with href attribute'.red.bold);

  scripts.forEach(function(item) {
    var text = item.outerHTML;
    // prevent assert on ga.js
    if(text.match(/ga\.js/)) return;
    assert.ok(text.match(/\.min.js/), text.red.bold + ' does not reference min file'.red.bold);
  });


  console.log(' ✔ Tests OK'.green.bold);

  process.exit(0);
});

