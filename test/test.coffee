test=require '../index.js'
assert=require 'assert'

testText="
it('should be able to run a case',function(){
  assert(true);
});

it('should be able to fail a case',function(){
  assert(false);
});
"

it 'should be able to run test',(done)->
  test.test
    test:testText
  ,(e,o)->
    console.log o.getLog()
    done()

