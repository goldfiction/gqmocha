vm = require "vm"
Mocha = require "mocha"
_ = require "lodash"
assert=require 'assert'
time=Date.now()

exports.test=(o,cb)->
  o=o||{}
  o.ui=o.ui||'bdd'
  o.reporter=o.reporter||'tap'
  o.context=o.context||{}
  #o.file=o.file||'/tmp/mocha'+time
  o.filter=o.filter||[]

  Log=""

  log=o.log||(obj)->
    if(obj)
      if typeof obj=="string"
        Log+='\n'+obj
      else if typeof obj=="object"
        Log+='\n'+JSON.stringify(obj,null,2)
      else
        Log+='\n'+obj+''

  context=
    'assert':assert
    'it':@it
    'log':log
  context=_.extend o.context,context

  filter=(hay)->
    for v in o.filter
      hay=replaceAll(v,"",hay)
    hay

  process.on 'uncaughtException',(err)->
    if(err&&err.stack)
      log(err.stack)
    else
      log(err)

  JSONReporter = (runner) ->
    self = this
    #mocha.reporters.Base.call this, runner
    tests = []
    pending = []
    failures = []
    passes = []
    runner.on 'test end', (test) ->
      tests.push test
      return
    runner.on 'pass', (test) ->
      passes.push test
    runner.on 'fail', (test,err) ->
      test.err=err
      failures.push test
    runner.on 'pending', (test) ->
      pending.push test
    runner.on 'end', ->
      obj =
        stats: self.stats
        tests: tests.map(clean)
        pending: pending.map(clean)
        failures: failures.map(clean)
        passes: passes.map(clean)
        stats:passes.length+' out of '+(passes.length + failures.length)+' cases passed'
      runner.testResults = obj
      o.output=filter(JSON.stringify(obj, null, 2))
      o.reporter='json'

  TAPReporter=(runner)->
    #mocha.reporters.Base.call(this, runner)

    self = this
    stats = this.stats
    n = 1
    passes = 0
    failures = 0;

    runner.on 'start', ->
      total = runner.grepTotal(runner.suite)
      log 1+'..'+total
    runner.on 'test end', ->
      ++n
    runner.on 'pending', (test) ->
      log 'ok '+n+' '+title(test)+' # SKIP -'
    runner.on 'pass', (test) ->
      passes++
      log 'ok '+n+' '+title(test)
    runner.on 'fail', (test, err) ->
      failures++
      log 'not ok '+n+' '+title(test)
      if err.stack
        log err.stack.replace(/^/gm, '  ')
    runner.on 'end', ->
      log ''
      log '# tests ' + (passes + failures)
      log '# pass ' + passes
      log '# fail ' + failures

      o.reporter='tap'
      o.output=filter(Log)

  if o.reporter=='json'
    mocha = new Mocha({ui:o.ui,reporter:JSONReporter})
  else
    mocha = new Mocha({ui:o.ui,reporter:TAPReporter})

  title=(test)->
    test.fullTitle().replace(/#/g, '')

  clean=(test)->
    title: test.title,
    fullTitle: test.fullTitle(),
    duration: test.duration,
    err: JSON.stringify(test.err || {},null,2)

  pseudoFile=(mocha, context, fileContent)->
    mocha.suite.emit "pre-require", context, ":memory:", mocha
    mocha.suite.emit "require", vm.runInNewContext(fileContent, context, {displayErrors: true}), ":memory:", mocha
    mocha.suite.emit "post-require", context, ":memory:", mocha

  pseudoFile mocha,context,o.test

  mocha.run ()->
    setTimeout ()->
      delete o.filter
      delete o.context
      cb(null,o)
    ,5

replaceAll = (find, replace, str)->
  find = find.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
  str.replace(new RegExp(find, 'g'), replace)


