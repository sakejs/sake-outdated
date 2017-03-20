import fs              from 'fs'
import {join, dirname} from 'path'

export default ->
  new Promise (resolve, reject) ->
    try
      require 'npm'
      resolve(true)
    catch err
      if /log.gauge.isEnabled/.test err.stack.toString()
        npmPath = join (dirname require.resolve 'npm'), '../'
        npmLog  = join npmPath, 'node_modules', 'npmlog'
        fs.exists npmLog, (exists) ->
          if exists
            exec "rm -rf #{npmLog}"
              .then  resolve
              .catch reject
