#
# The root services resource. This resource should simple return metadata about the version of the services.
#
class RootResource
  constructor: (@app) ->

  get: (req, res) =>
    metadata =
      name: @app.get('name')
      description: @app.get('description')
      version: @app.get('version')

    res.send(metadata)

module.exports = RootResource
