// Generated by CoffeeScript 1.6.3
(function() {
  var assert, test, testText;

  test = require('../index.js');

  assert = require('assert');

  testText = "it('should be able to run a case',function(done){  assert(true);  done();});it('should be able to fail a case',function(done){  log('hello world!');  assert(false);  done();});";

  it('should be able to run test', function(done) {
    return test.test({
      test: testText
    }, function(e, o) {
      return done();
    });
  });

}).call(this);

/*
//@ sourceMappingURL=test.map
*/
