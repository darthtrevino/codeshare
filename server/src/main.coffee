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
app.listen(port)
console.log "Listening to requests on port #{port}. ===#{config.ConfigName}=== #{config.Database.connectionString}"
