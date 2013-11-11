service = (uri) -> "/services/#{uri}"

class Router
  constructor: (@app, @routeMaker, @resources) ->

  route: ->
    # The standard HTML index
    @app.get('/', @resources.Index)

    # The service root
    @app.get(service('/'), @resources.Root.get)

    # Set up crud routes for top-level entities
    @routeMaker.makeCrudRoutes(service('users'), @resources.Users, "all")

module.exports = Router
