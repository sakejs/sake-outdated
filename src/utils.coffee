import replacements from './replacements'


# Log helper to replace messages with our defaults
export log = (stdout, stderr) ->
  stdout = stdout.trim()
  stderr = stderr.trim()

  for {from, to} in replacements
    stdout = stdout.replace from, to

  console.log   stdout if stdout
  console.error stderr if stderr


# Split stdout lines, skipping header/footer text
export splitLines = (stdout) ->
  lines = stdout.trim().split '\n'

  # Trim header/footer
  lines = lines.slice 1, -1

  # Clear any trailing newlines
  lines = lines.join('\n').trim().split '\n'

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


# Check stdout to see if we need to commit changes
export needsUpdate = (stdout) ->
  /Upgraded .*package\.json/.test stdout


# Strip ncu -a message
export stripNcu = (stdout) ->
  messages = [
    '\nThe following dependencies are satisfied by their declared version range, but the installed versions are behind. You can install the latest versions without modifying your package file by using npm update. If you want to update the dependencies in your package file anyway, run ncu -a.\n'
    '\nThe following dependency is satisfied by its declared version range, but the installed version is behind. You can install the latest version without modifying your package file by using npm update. If you want to update the dependency in your package file anyway, run ncu -a.\n'
  ]
  for msg in messages
    stdout = stdout.replace msg, ''
  stdout
