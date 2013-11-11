express = require('express')
passport = require('passport')
path = require('path')

class Configurator
  constructor: (@app, @serverConfig) ->

  configure: ->
    #
    # Configure Persistence
    #
    ModelIndex = require('./models')
    @app.set('models', ModelIndex.Models)
    @app.set('modelIndex', ModelIndex)
    @app.set('authHandler', (req, res, done) -> done())

    #
    # Wire up the Middleware
    #
    @app.set('port', process.env.PORT || @serverConfig.listenPort)
    @app.set('views', __dirname + '/views')
    @app.set('view engine', 'jade')
    @app.use(express.favicon())
    @app.use(express.logger('dev'))
    @app.use(express.bodyParser())
    @app.use(express.methodOverride())
    @app.use(express.cookieParser(@serverConfig.cookieParserSecret))
    @app.use(express.session())
    @app.use(@app.router)
    @app.use(express.static(path.join(__dirname, '/public')))
    @app.use(passport.initialize())

    if @serverConfig.useLiveReload
      @app.use(require('connect-livereload')({
        port: @serverConfig.liveReloadPort
      }))

    #
    # Environment-specific options
    #
    if @serverConfig.useExpressErrorHandler
      @app.use(express.errorHandler())

    #
    # Metadata
    #
    @app.set('name', 'retrace-api')
    @app.set('description', 'A RESTful API for the retrace e-waste platform.')
    @app.set('version', @serverConfig.version)


module.exports = Configurator