RootResource = require('./root')
SimpleCrudResource = require('./simple_crud_resource')

#
# The RESTful resources of the application
#
class Resources
  constructor: (@app) ->
    models = @app.get('models')

    # Root and Index
    @Index = (req, res) -> res.redirect('index.html')
    @Root = new RootResource(@app)

    # Top-Level Service Resources
    @Users = new SimpleCrudResource(models.User)

module.exports = Resources