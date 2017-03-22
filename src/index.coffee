import path from 'path'

import npmFix from './npmfix'
import update from './update'
import {gitOk, log, splitLines, parseDeps} from './utils'

needsUpdate = (stdout) ->
  deps = parseDeps splitLines stdout
  if deps.length
    true
  else
    false

export default (opts = {}) ->
  opts.commit ?= true

  # Find path to node-check-updates binary
  # TODO: Figure out why npm does not correctly symlink it's binary
  ncu = path.join (path.dirname (require.resolve 'npm4-check-updates')), '../bin/ncu'

  task 'outdated', 'show outdated packages', ->
    return unless yield npmFix()

    {stdout, stderr, status} = yield exec.quiet ncu
    log stdout, stderr
    process.exit status if status != 0

  task 'outdated:update', 'update outdated packages', ->
    return unless yield npmFix()
    return unless yield gitOk()

    {stdout, stderr, status} = yield exec.quiet ncu + ' -u'
    log stdout, stderr
    process.exit status if status != 0

    if needsUpdate stdout
      yield update stdout if opts.commit

  task 'outdated:all', 'update all outdated packages', ->
    return unless yield npmFix()
    return unless yield gitOk()

    {stdout, stderr, status} = yield exec.quiet ncu + ' -ua'
    log stdout, stderr
    process.exit status if status != 0

    if needsUpdate stdout
      yield update stdout if opts.commit
