exec = require 'executive'

describe 'cake-yarn', ->
  it 'should add yarn commands', ->
    {stdout} = yield exec 'cake', cwd: __dirname
    stdout.should.contain 'install'
    stdout.should.contain 'add'
    stdout.should.contain 'init'
