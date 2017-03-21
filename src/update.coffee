import exec from 'executive'
import fs   from 'fs'
import tmp  from 'tmp'

import {splitLines, parseDeps} from './utils'

write = (data) ->
  new Promise (resolve, reject) ->
    tmp.file (err, path, fd) ->
      return reject err if err?

      fs.writeFile fd, data, (err) ->
        if err?
          reject err
        else
          resolve path

# Commit changes + run npm or yarn update
export default (stdout) ->
  lines   = splitLines stdout
  deps    = parseDeps lines
  message = """
    Update #{deps.join ', '}

    #{lines.join '\n'}
    """

  path = null
  cmds = [
    'git add .'
    -> (write message).then (v) -> path = v
    -> "git commit -F #{path}"
  ]

  if tasks.has 'yarn:upgrade'
    # Ensure yarn runs first so yarn.lock file is committed
    cmds.unshift 'yarn upgrade'
  else
    # Otherwise run npm update last
    cmds.push 'npm update'

  exec cmds
