class CrudResource
  #
  # Constructs an instance of a CrudResource
  # @param Listing: The Listing Model
  #
  constructor: (@app, @model) ->

  #
  # An HTTP Handler that lists all items in a model using paging parameters in the query.
  #
  listAllHandler: (req, res) =>
    @emitNotImplemented('ListAll', res)

  createHandler: (req, res) =>
    @emitNotImplemented('Create', res)

  updateHandler: (req, res) =>
    @emitNotImplemented('Update', res)

  deleteHandler: (req, res) =>
    @emitNotImplemented('Delete', res)

  getByIdHandler: (req, res) =>
    @emitNotImplemented('GetById', res)

  searchHandler: (req, res) =>
    @emitNotImplemented('Search', res)

  #
  # Emits an HTTP 501 Error
  #
  emitNotImplemented: (methodName, res) ->
    res.status(501).send("#{methodName} not implemented")

  #
  # Emits an error response
  #
  emitError: (res, err) ->
    isCastingError = err.name == 'CastError'
    status = if isCastingError then 400 else 500
    res.status(status).send(err)

module.exports = CrudResource