// Generated by CoffeeScript 1.6.3
(function() {
  var Mocha, assert, fs, time, vm, _;

  vm = require("vm");

  Mocha = require("mocha");

  _ = require("lodash");

  assert = require('assert');

  fs = require('fs');

  time = Date.now();

  exports.test = function(o, cb) {
    var access, context, getLog, log, logtext, mocha, pseudoFile, stderrtemp, stdouttemp;
    o = o || {};
    o.reporter = o.reporter || 'bdd';
    o.context = o.context || {};
    o.file = o.file || '/tmp/mocha' + time;
    logtext = "";
    log = function(obj) {
      if (obj) {
        if (typeof obj === "string") {
          return logtext += obj;
        } else if (typeof obj === "object") {
          return logtext += JSON.stringify(obj, null, 2);
        } else {
          return logtext += obj + '';
        }
      }
    };
    getLog = function() {
      return logtext;
    };
    context = {
      assert: assert,
      it: this.it,
      log: log,
      console: console
    };
    mocha = new Mocha({
      ui: o.reporter
    });
    pseudoFile = function(mocha, context, fileContent) {
      mocha.suite.emit("pre-require", context, ":memory:", mocha);
      mocha.suite.emit("require", vm.runInNewContext(fileContent, context, {
        displayErrors: true
      }), ":memory:", mocha);
      return mocha.suite.emit("post-require", context, ":memory:", mocha);
    };
    pseudoFile(mocha, context, o.test);
    access = fs.createWriteStream(o.file);
    stdouttemp = process.stdout.write;
    stderrtemp = process.stderr.write;
    process.stdout.write = process.stderr.write = access.write.bind(access);
    o.getLog = getLog;
    o.mocha = o.mocha;
    o.run = mocha.run;
    return mocha.run(function() {
      process.stdout.write = stdouttemp;
      process.stderr.write = stderrtemp;
      return cb(null, o);
    });
  };

}).call(this);

/*
//@ sourceMappingURL=index.map
*/
