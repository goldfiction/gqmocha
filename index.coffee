vm = require "vm"
Mocha = require "mocha"
_ = require "lodash"
assert=require 'assert'
fs=require 'fs'
time=Date.now()

exports.test=(o,cb)->
  o=o||{}
  o.reporter=o.reporter||'bdd'
  o.context=o.context||{}
  o.file=o.file||'/tmp/mocha'+time

  logtext=""

  log=(obj)->
    if(obj)
      if typeof obj=="string"
        logtext+=obj
      else if typeof obj=="object"
        logtext+=JSON.stringify(obj,null,2)
      else
        logtext+=obj+''

  getLog=()->
    return logtext

  context=
    assert:assert
    it:@it
    log:log
    console:console

  #o.context=_.extend context,o.context

  mocha = new Mocha
    ui:o.reporter

  pseudoFile=(mocha, context, fileContent)->
    mocha.suite.emit "pre-require", context, ":memory:", mocha
    mocha.suite.emit "require", vm.runInNewContext(fileContent, context, {displayErrors: true}), ":memory:", mocha
    mocha.suite.emit "post-require", context, ":memory:", mocha

  pseudoFile mocha,context,o.test

  access = fs.createWriteStream(o.file);

  stdouttemp=process.stdout.write
  stderrtemp=process.stderr.write
  process.stdout.write = process.stderr.write = access.write.bind(access);

  o.getLog=getLog
  o.mocha=o.mocha
  o.run=mocha.run

  mocha.run ()->
    process.stdout.write=stdouttemp
    process.stderr.write=stderrtemp
    cb null,o
