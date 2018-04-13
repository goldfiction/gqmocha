test=require '../index.js'

testText="
it('should be able to run a case',function(done){
  assert(true);
  done();
});

it('should be able to fail a case',function(done){
  assert(false);
  done();
});
"

test.test
  test:testText  # pass in your test in string format
,(e,o)->
  console.log o.output  # grab your mocha test result from o.output
