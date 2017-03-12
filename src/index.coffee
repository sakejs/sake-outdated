import exec from 'executive'
import path from 'path'

replacements =
  'Run ncu with -u to upgrade package.json': 'Run `cake upgrade` to upgrade package.json'

log = (stdout, stderr) ->
  stdout = stdout.trim()
  stderr = stderr.trim()

  for k,v of replacements
    stdout = stdout.replace k, v

  console.log   stdout if stdout
  console.error stderr if stderr

export default (opts = {}) ->
  opts.packageFile ?= path.join process.cwd(), 'package.json'

  task 'outdated', 'show outdated packages', ->
    {stdout, stderr} = yield exec.quiet 'ncu'
    log stdout, stderr

  task 'upgrade', 'upgrade outdated packages', ->
    {stdout, stderr} = yield exec.quiet 'ncu -u'
    log stdout, stderr

  task 'upgrade:all', 'upgrade outdated packages', ->
    {stdout, stderr} = yield exec.quiet 'ncu -a'
    log stdout, stderr
