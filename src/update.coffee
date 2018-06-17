import fs  from 'fs'
import tmp from 'tmp'

import {gitExists, parseDeps, splitLines} from './utils'

write = (data) ->
  new Promise (resolve, reject) ->
    tmp.file (err, path, fd) ->
      return reject err if err?

      fs.writeFile fd, data, (err) ->
        if err?
          reject err
        else
          resolve path

formatMessage = (stdout) ->
  lines = splitLines stdout
  deps  = parseDeps lines

  """
  Update #{deps.join ', '}

  #{lines.join '\n'}
  """

gitCommit = (stdout) ->
  message = formatMessage stdout
  path    = null

  [
    'echo'
    'git add .'
    -> (write message).then (v) -> path = v
    -> "git commit -F #{path}"
  ]

# Commit changes + run npm or yarn update
export default (stdout) ->
  new Promise (resolve, reject) ->

    # Check if we're in a git repo
    gitExists().then (exists) ->
      cmds = []

      # Do yarn upgrade / npm update
      if tasks.has 'yarn:upgrade'
        cmds.push 'yarn upgrade'
      else
        cmds.push 'npm update'

      # Add commit message if we're in a git repo
      cmds = cmds.concat gitCommit stdout if exists

      # Do update
      exec.quiet cmds
        .then (res) ->
          # Execute adds an extra newline, so we trim that here but preserve
          # stderr (in case it exists)
          console.log '\n' + res.stdout.trim()
          console.log res.stderr if res.stderr != ''
          resolve true
        .catch reject
