#
# All of the retrace domain services will emit application/json.
# - ctrevino, 9/3/2013
#
MEDIA_TYPE_JSON = 'application/json'

#
# Defines the path for a singular sub-resource of a parent list-resource
#
singularResourcePath = (root, id="id") -> "#{root}/:#{id}"
searchResourcePath = (root) -> "#{root}/search"

#
# An HTTP handler method that does nothing
#
emptyHandler = (req, res, next) -> next()

#
# A router class that can generate idiomatic route sets
#
class RouteCreator
  constructor: (@app, @headerInspector, @pager) ->
    @authHandler = app.get('authHandler')
    # Create HTTP Handlers
    assertAcceptsJson = @headerInspector.assertAcceptsHandler(MEDIA_TYPE_JSON)
    normalizePaging = @pager.normalizePagingHandler()

    # Set up the handler chains
    @singleResourceHandlers = [ assertAcceptsJson ]
    @listResourceHandlers = [ assertAcceptsJson, normalizePaging ]

  #
  # Gets an Auth-Handler method to use. If the resource should be protected, then a real auth handler is used.
  #
  getAuthHandler: (protectedResource) -> if protectedResource then @authHandler else emptyHandler

  #
  # Wires up a set of simple CRUD routes for a resource, including read-only and mutable routes.
  #
  #  GET    /root/
  #  GET    /root/:id
  #  POST   /root/
  #  PUT    /root/:id
  #  DELETE /root/:id
  #
  makeCrudRoutes: (root, resource, authOptions=null) ->
    @makeReadOnlyRoutes(root, resource, authOptions)
    @makeMutableRoutes(root, resource, authOptions)

  #
  # Wires up standard mutable routes for a resource
  #
  #  POST   /root/
  #  PUT    /root/:id
  #  DELETE /root/:id
  #
  makeMutableRoutes: (root, resource, authOptions=null) ->
    if !resource then throw new Error("Resource for #{root} is undefined")

    authHandler = @getAuthHandler(authOptions is 'all' or authOptions is 'mutable')
    handlers = [authHandler].concat(@singleResourceHandlers)
    @app.post(root, handlers, resource.createHandler) #TODO: open up post in a special mode
    @app.put(singularResourcePath(root), handlers, resource.updateHandler)
    @app.delete(singularResourcePath(root), handlers, resource.deleteHandler)

  #
  # Wires up standard read routes for a resource
  #
  #  GET    /root/
  #  GET    /root/:id
  #
  makeReadOnlyRoutes: (root, resource, authOptions=null) ->
    if !resource then throw new Error("Resource for #{root} is undefined")
    authHandler = @getAuthHandler(authOptions is 'all')

    listHandlers = [authHandler].concat(@listResourceHandlers)
    singleHandlers = [authHandler].concat(@singleResourceHandlers)

    @app.get(root, listHandlers, resource.listAllHandler)
    @app.get(singularResourcePath(root), singleHandlers, resource.getByIdHandler)
    @app.post(searchResourcePath(root), singleHandlers, resource.searchHandler)

module.exports = RouteCreator