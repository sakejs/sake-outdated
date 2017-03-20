import exec from 'executive'
import fs   from 'fs'
import tmp  from 'tmp'

import {splitLines, parseDeps} from './utils'

# Commit changes + run npm or yarn update
export default (stdout) ->
  lines = splitLines stdout
  deps  = parseDeps lines
  path  = null

  message = """
    Update #{deps.join ', '}

    #{lines.join '\n'}
    """

  writeMessage = ->
    new Promise (resolve, reject) ->
      tmp.file (err, path, fd) ->
        return reject err if err?

        fs.writeFile fd, message, (err) ->
          if err?
            reject err
          else
            resolve path

  cmds = [
    'git add .'
    -> writeMessage.then (v) -> path = v
    -> "git commit -F #{path}"
  ]

  if tasks.has 'yarn:upgrade'
    # Ensure yarn runs first so yarn.lock file is committed
    cmds.unshift 'yarn upgrade'
  else
    # Otherwise run npm update last
    cmds.push 'npm update'

  exec cmds
