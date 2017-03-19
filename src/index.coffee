import path from 'path'

import update       from './update'
import {gitOk, log} from './utils'


export default (opts = {}) ->
  opts.commit ?= true

  # Find path to node-check-updates binary
  # TODO: Figure out why npm does not correctly symlink it's binary
  ncu = path.join (path.dirname (require.resolve 'npm-check-updates')), '../bin/ncu'

  task 'outdated', 'show outdated packages', ->
    {stdout, stderr, status} = yield exec.quiet ncu
    log stdout, stderr
    process.exit status if status != 0

  task 'outdated:update', 'update outdated packages', ->
    return unless yield gitOk()

    {stdout, stderr, status} = yield exec.quiet ncu + ' -u'
    log stdout, stderr
    process.exit status if status != 0

    yield update stdout if opts.commit

  task 'outdated:all', 'update all outdated packages', ->
    return unless yield gitOk()

    {stdout, stderr, status} = yield exec.quiet ncu + ' -ua'
    log stdout, stderr
    process.exit status if status != 0

    yield update stdout if opts.commit
