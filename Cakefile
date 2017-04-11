use 'sake-bundle'
use 'sake-outdated'
use 'sake-publish'
use 'sake-test'
use 'sake-version'

# use 'sake-yarn'

try
  use require './'
catch err

task 'build', 'build project', ->
  bundle.write
    entry: 'src/index.coffee'
    compilers:
      coffee: version: 1

task 'clean', 'clean project', ->
  exec 'rm -rf lib'
