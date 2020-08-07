test=require '../index.js'
fs=require 'fs'

testText=fs.readFileSync 'test/test.txt'

test.test
  test:testText  # pass in your test in string format
,(e,o)->
  console.log o.output  # grab your mocha test result from o.output
