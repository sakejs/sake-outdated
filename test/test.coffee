exec = require 'executive'

describe 'sake-outdated', ->
  it 'should add outdated commands', ->
    {stdout} = yield exec 'sake', cwd: __dirname
    stdout.should.contain 'outdated'
    stdout.should.contain 'outdated:update'
    stdout.should.contain 'outdated:all'
