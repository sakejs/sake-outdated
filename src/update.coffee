import exec from 'executive'
import fs   from 'fs'
import tmp  from 'tmp'

# Split stdout lines, skipping header/footer text
splitLines = (stdout) ->
  lines = stdout.split '\n'

  # Trim header/footer
  lines = lines.slice 2, -4

  # Normalize spacing
  for line, i in lines
    lines[i] = '  ' + line.trim()

  # Trim satisfied but behind message
  for line, i in lines
    if /The following dependencies/.test line
      return lines.slice 0, i

  lines

# Reads updated deps from output of command
parseDeps = (lines) ->
  for dep in lines
    (dep.trim().split ' ').shift()

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
      tmp.file (err, _path, fd) ->
        console.log 'err creating tmp file:', err
        return reject err if err?

        console.log 'created temporary file', path

        path = _path # save reference to tmp file path

        fs.writeFile fd, msg, (err) ->
          if err?
            console.log 'failed to write commit message'
            reject err
          else
            console.log 'wrote commit message'
            resolve()

  cmds = [
    'git add .'
    ->
      console.log 'trying to writeMessage'
      writeMessage()
    ->
      console.log "commiting #{path}"
      "git commit -F #{path}"
  ]

  if tasks.has 'yarn:upgrade'
    cmds.unshift 'yarn upgrade'
  else
    cmds.push 'npm update'

  exec cmds
