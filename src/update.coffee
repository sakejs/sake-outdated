import exec from 'executive'
import fs   from 'fs'
import tmp  from 'tmp'

# Split stdout lines, skipping header/footer text
splitLines = (stdout) ->
  lines = stdout.split '\n'
  lines.slice 2, -4

# Reads updated deps from output of command
parseDeps = (lines) ->
  for dep in lines
    (dep.trim().split ' ').shift()

# sync message write method for git commit messages
writeMessage = (message) ->

# Commit changes + run npm or yarn update
export default (stdout) ->
  lines = splitLines stdout
  deps  = parseDeps lines

  message = """
    Updated #{deps.join ', '}

    #{lines.join '\n'}
    """

  new Promise (resolve, reject) ->
    tmp.file (err, path, fd) ->
      fs.writeFile fd, message, (err) ->
        return reject err if err?

        cmds = [
          'git add .'
          "git commit -F #{path}"
          'rm message.txt'
        ]

        if tasks.has 'yarn:upgrade'
          cmds.unshift 'yarn upgrade'
        else
          cmds.push 'npm update'

        exec cmds
          .then resolve
          .catch reject
