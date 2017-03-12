require 'shortcake'

use 'cake-publish'
use 'cake-test'
use 'cake-version'

use require './'

task 'build', 'build project', ->
  handroll = require 'handroll'

  bundle = yield handroll.bundle
    entry:     'src/index.coffee'
    external:  true
    sourceMap: true

  yield bundle.write format: 'cjs'
  yield bundle.write format: 'es'

task 'clean', 'clean project', ->
  exec 'rm -rf dist'
