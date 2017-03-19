import fs   from 'fs'
import exec from 'executive'

# Split stdout lines, skipping header/footer text
splitLines = (stdout) ->
  lines = stdout.split '\n'
  lines.slice 2, -4

# Reads updated deps from output of command
parseDeps = (lines) ->
  lines = stdout.split '\n'
  for dep in lines.slice 2, -4
    (dep.trim().split ' ').shift()

# Commit changes + run npm or yarn update
export default (stdout) ->
  lines = splitLines stdout
  deps  = parseDeps lines

  message = """
    Updated #{deps.join ', '}

    #{lines.join '\n'}
    """

  new Promise (resolve, reject) ->
    fs.writeFile 'message.txt', message, (err) ->
      return reject err if err?

      cmds = [
        'git add .'
        'git commit -F message.txt'
        'rm message.txt'
      ]

      if tasks.has 'yarn:upgrade'
        cmds.unshift 'yarn upgrade'
      else
        cmds.push 'npm update'

      exec cmds
        .then resolve
        .catch reject
