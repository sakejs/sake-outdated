import exec from 'executive'

import replacements from './replacements'

# Log helper to replace messages with our defaults
export log = (stdout, stderr) ->
  stdout = stdout.trim()
  stderr = stderr.trim()

  for {from, to} in replacements
    stdout = stdout.replace from, to

  console.log   stdout if stdout
  console.error stderr if stderr

# Checks whether the local git working directory is clean or not
export gitOk = ->
  new Promise (resolve, reject) ->
    exec.quiet 'git status --porcelain'
      .then ({stderr, stdout}) ->
        if stderr or stdout
          reject new Error 'Git working directory not clean'
        else
          resolve true
