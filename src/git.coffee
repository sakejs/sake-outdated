import fs  from 'fs'
import tmp from 'tmp'
import {parseDeps, splitLines} from './utils'


# Generate commit message for git
generateMessage = (stdout) ->
  lines = splitLines stdout
  deps  = parseDeps lines

  """
  Update #{deps.join ', '}

  #{lines.join '\n'}
  """


# Write commit to temporary file
writeMessage = (data) ->
  new Promise (resolve, reject) ->
    tmp.file (err, path, fd) ->
      return reject err if err?

      fs.writeFile fd, data, (err) ->
        if err?
          reject err
        else
          resolve path


# Checks whether the local git directory exists
export gitExists = ->
  new Promise (resolve, reject) ->
    exec.quiet 'git rev-parse --git-dir'
      .then ({stderr}) ->
        if /fatal: Not a git repository/.test stderr
          resolve false
        else
          resolve true


# Checks whether the local git working directory is clean or not
export gitOk = ->
  new Promise (resolve, reject) ->
    gitExists().then (exists) ->
      return resolve true unless exists

      exec.quiet 'git status --porcelain'
        .then ({stderr, stdout}) ->
          if stderr or stdout
            console.error stdout+stderr
            reject new Error 'Git working directory not clean'
          else
            resolve true


# Commit changes + run npm or yarn update
export gitCommit = (stdout) ->
  new Promise (resolve, reject) ->

    # Check if we're in a git repo
    gitExists().then (exists) ->
      return resolve true unless exists

      # Generate message, add files and commit
      new Promise (resolve, reject) ->
        message = generateMessage stdout
        path    = null

        cmds = [
          'git add .'
          -> (writeMessage message).then (v) -> path = v
          -> "git commit -F #{path}"
        ]

        exec.quiet cmds
          .then (res) ->
            console.log res.stdout.trim()
            console.log res.stderr.trim() if res.stderr != ''
            resolve true
          .catch reject
