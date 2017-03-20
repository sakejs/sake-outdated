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

  message = """
    Update #{deps.join ', '}

    #{lines.join '\n'}
    """

  new Promise (resolve, reject) ->
    tmp.file (err, path, fd) ->
      fs.writeFile fd, message, (err) ->
        return reject err if err?

        cmds = [
          'git add .'
          "git commit -F #{path}"
          "rm #{path}"
        ]

        if tasks.has 'yarn:upgrade'
          cmds.unshift 'yarn upgrade'
        else
          cmds.push 'npm update'

        exec cmds
          .then resolve
          .catch reject
