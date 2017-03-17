import exec from 'executive'
import path from 'path'

replacements = [
  from: 'Run ncu with -u to upgrade package.json'
  to:   "Run 'cake upgrade' to update your package.json"
,
  from: 'The following dependencies are satisfied by their declared version range, but the installed versions are behind. You can install the latest versions without modifying your package file by using npm update. If you want to update the dependencies in your package file anyway, run ncu -a.'
  to:   """
  The following dependencies are satisfied by their declared version ranges. Run
  'cake upgrade:all' to update your package.json to specify the latest versions.
  """
,
  from: 'The following dependency is satisfied by its declared version range, but the installed version is behind. You can install the latest version without modifying your package file by using npm update. If you want to update the dependency in your package file anyway, run ncu -a.'
  to:   """
  The following dependency is satisfied by its declared version range. Run 'cake
  upgrade:all' to update your package.json to specify the latest version instead.
  """
,
  from: 'All dependencies match the latest package versions :)'
  to:   'All dependencies up to date'
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

  ncu = path.join (path.dirname (require.resolve 'npm-check-updates')), '../bin/ncu'

  task 'outdated', 'show outdated packages', ->
    {stdout, stderr, status} = yield exec.quiet ncu
    log stdout, stderr
    process.exit status if status != 0

  task 'outdated:update', 'update outdated packages', ->
    {stdout, stderr, status} = yield exec.quiet ncu + ' -u'
    'ncu -u'
    log stdout, stderr
    process.exit status if status != 0
    exec 'npm update'

  task 'outdated:all', 'update outdated all packages', ->
    {stdout, stderr, status} = yield exec.quiet ncu + ' -ua'
    log stdout, stderr
    process.exit status if status != 0
    exec 'npm update'
