#
# Module dependencies.
#
http = require('http')
config = require('config')

#
# App Creation
#
express = require('express')
app = express()

#
# App Configuration
#
Configurator = require('./configurator')
config = require('config')
new Configurator(app, config.Server).configure()

#
# Resource Routing
#
RouteCreator = require('./route_creator')
HeaderInspector = require('./request_handlers/header_inspector')
Pager = require('./request_handlers/pager')
Router = require('./router')
Resources = require('./resources')

routeCreator = new RouteCreator(app, new HeaderInspector(), new Pager())
resources = new Resources(app)
router = new Router(app, routeCreator, resources)
router.route()

#
# Bootstrap the HTTP server
#
port = app.get('port')

#
# Set up ShareJS
#
sharejs = require('share')
#server = connect(connect.logger(), connect.static(__dirname + '/my_html_files'))

# See docs for options. {type: 'redis'} to enable persistance.
options =
  preValidate: false
  db:
    type: 'none'

options =
  db: { type: 'none' }
  #browserChannel: { cors: '*' }
  browserChannel: {}
  auth: (client, action) ->
    if (action.name == 'submit op' && action.docName.match(/^readonly/))
      action.reject()
    else
      action.accept()

# Lets try and enable redis persistance if redis is installed...
try
  require('redis')
  options.db = {type: 'redis'}
catch e
  console.log "could not load redis"

console.log("ShareJS example server v" + sharejs.version)
console.log("Options: ", options)

# Attach the sharejs REST and Socket.io interfaces to the server
sharejs.server.attach(app, options)


# Attach the sharejs REST and Socket.io interfaces to the server
app.use(sharejs, options)
#console.log "SHAREJS: #{sharejs}, #{Object.keys(sharejs.server.createClient(options))}"
#sharejs.attach(app, options)

#
# Launch El Serverdor
#
app.listen(port)
console.log "Listening to requests on port #{port}. ===#{config.ConfigName}=== #{config.Database.connectionString}"

process.on('uncaughtException', (err) ->
  console.error 'An error has occurred. Please file a ticket here: https://github.com/josephg/ShareJS/issues'
  console.error 'Stack Trace: ' + err.stack
)
