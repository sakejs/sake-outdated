require 'shortcake'

use 'cake-bundle'
use 'cake-publish'
use 'cake-test'
use 'cake-version'
use 'cake-yarn'

use require './'

task 'build', 'build project', ->
  bundle.write
    entry:     'src/index.coffee'
    external:  true
    sourceMap: true
    formats:   ['cjs', 'es']

task 'clean', 'clean project', ->
  exec 'rm -rf dist'
