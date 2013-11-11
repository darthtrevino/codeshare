CrudResource = require('./crud_resource')
ListResult = require('../responses/list_result')

identity = (p) -> p

#
# The SimpleCrudResource class which defines idiomatic request handlers
#
class SimpleCrudResource extends CrudResource
  constructor:  (@model, @payloadProcessor=identity) ->

  #
  # An HTTP Handler that lists all items in a model using paging parameters in the query.
  #
  listAllHandler: (req, res) =>
    model = @model
    offset = req.query.offset
    limit = req.query.limit
    payload = new ListResult(@payloadProcessor)
    emitError = @emitError

    @model.find().skip(offset).limit(limit).execQ()
      .then((foundItems) -> payload.addItems(foundItems))
      .then( -> model.countQ())
      .then((count) -> payload.totalResultCount = count)
      .then( -> res.send(payload))
      .fail((err) -> emitError(res, err))
      .done()
  #
  # An HTTP Handler that will retrieve an entity by its unique database id
  #
  getByIdHandler: (req, res) =>
    id = req.params.id
    emitError = @emitError
    payloadProcessor = @payloadProcessor

    @model.findByIdQ(id)
      .then((found) ->
        if found is null
          res.status(404).send(null)
        else
          result = found.toObject()
          res.send(payloadProcessor(result)))
      .fail((err) -> emitError(res, err))
      .done()

  #
  # An HTTP Handler that can be used to create new entities
  #
  createHandler: (req, res) =>
    entity = req.body
    emitError = @emitError
    payloadProcessor = @payloadProcessor

    @model.createQ(entity)
      .then((saved) -> res.send(payloadProcessor(saved.toObject())))
      .fail((err) -> emitError(res, err))
      .done()

  #
  # An HTTP Handler that can be used to update entities
  #
  updateHandler: (req, res) =>
    id = req.params.id
    entity = req.body
    emitError = @emitError
    payloadProcessor = @payloadProcessor

    # Remove Mongo-Specific Fields
    delete entity._id
    delete entity.__v

    # Find the persisted entity
    @model.findByIdAndUpdateQ(id, entity)
      .then((result) ->
        if result is null
          res.status(404).send(null)
        else
          res.send(payloadProcessor(result.toObject())))
      .fail((err) -> emitError(res, err))
      .done()

  #
  # An HTTP Handler that can be used to delete entities
  #
  deleteHandler: (req, res) =>
    id = req.params.id
    emitError = @emitError

    @model.findByIdAndRemoveQ(id)
      .then((result) ->
          status = if result is null then 404 else 204
          res.status(status).send(null))
      .fail((err) -> emitError(res, err))
      .done()

  #
  # An HTTP Handler that can be used for entity searches using MongoDB search semantics
  #
  searchHandler: (req, res) =>
    model = @model
    conditions = req.body
    offset = req.query.offset
    limit = req.query.limit
    emitError = @emitError
    payload = new ListResult(@payloadProcessor)

    @model.find(conditions).skip(offset).limit(limit).execQ()
      .then((foundItems) -> payload.addItems(foundItems))
      .then( -> model.countQ(conditions))
      .then((count) -> payload.totalResultCount = count)
      .then( -> res.send(payload))
      .fail((err) -> emitError(res, err))
      .done()

module.exports = SimpleCrudResource