import fs from 'fs'
import {join, dirname} from 'path'


# Fix long-standing bug with various versions of npm
export npmFix = ->
  new Promise (resolve, reject) ->
    try
      require 'npm'
      resolve(true)
    catch err
      if /log.gauge.isEnabled/.test err.stack.toString()
        console.log 'Attempting to fix npm...'
        npmPath = join (dirname require.resolve 'npm'), '../'
        npmLog  = join npmPath, 'node_modules', 'npmlog'

        fs.exists npmLog, (exists) ->
          if exists
            cmd = "rm -rf #{npmLog}"
            console.log cmd
            exec cmd
              .then  resolve
              .catch reject
          else
            reject 'Unable to apply npmfix'


# Do yarn upgrade / npm update
export npmInstall = ->
  if tasks.has 'yarn:upgrade'
    exec '''
         echo
         echo $ yarn upgrade
         yarn upgrade
         '''
  else
    exec '''
         echo
         echo $ npm install
         npm install
         '''
