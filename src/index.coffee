import exec from 'executive'
import path from 'path'

replacements = [
  from:   'Run ncu with -u to upgrade package.json'
  to:     "Use 'cake upgrade' to upgrade your package.json"
,
  from: 'The following dependencies are satisfied by their declared version range, but the installed versions are behind. You can install the latest versions without modifying your package file by using npm update. If you want to update the dependencies in your package file anyway, run ncu -a.'
  to:   "The following dependencies are satisfied by thir declared range. You can update your package file anyways by using 'cake upgrade:all'"
]

log = (stdout, stderr) ->
  stdout = stdout.trim()
  stderr = stderr.trim()

  for {from, to} in replacements
    stdout = stdout.replace from, to

  console.log   stdout if stdout
  console.error stderr if stderr

export default (opts = {}) ->
  opts.packageFile ?= path.join process.cwd(), 'package.json'

  task 'outdated', 'show outdated packages', ->
    {stdout, stderr, status} = yield exec.quiet 'ncu'
    log stdout, stderr
    process.exit status if status != 0

  task 'upgrade', 'upgrade outdated packages', ->
    {stdout, stderr, status} = yield exec.quiet 'ncu -u'
    log stdout, stderr
    process.exit status if status != 0
    invoke 'install' if tasks.has 'install'

  task 'upgrade:all', 'upgrade outdated packages', ->
    {stdout, stderr} = yield exec.quiet 'ncu -a'
    log stdout, stderr
    process.exit status if status != 0
    invoke 'install' if tasks.has 'install'
