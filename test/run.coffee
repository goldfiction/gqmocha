test=require '../index.js'

testText="
it('should be able to run a case',function(done){
  assert(true);
  console.log('hello');
  done();
});

it('should be able to fail a case',function(done){
  assert(false);
  done();
});
"

test.test
  test:testText
,(e,o)->
  console.log o.file