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

# Split stdout lines, skipping header/footer text
export splitLines = (stdout) ->
  lines = stdout.split '\n'

  # Trim header/footer
  lines = lines.slice 2, -4

  # Normalize spacing
  for line, i in lines
    lines[i] = '  ' + line.trim()

  # Trim satisfied but behind message
  for line, i in lines
    if /The following dependenc/.test line
      return lines.slice 0, i

  lines

# Reads updated deps from output of command
export parseDeps = (lines) ->
  for dep in lines
    dep = (dep.trim().split ' ').shift()
    continue if dep == ''
    dep
