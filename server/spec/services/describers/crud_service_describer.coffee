httpMatchers = require('../../http_matchers')
HttpRunner = require('../../http_runner')
runner = new HttpRunner()

#
# Data Provider Objects
#  newEntity
#  updateEntity
#  extractId: (entity) ->
#  unknownId:
#  illegalId:
#  searchObject:
#

#
# Tests for the /services/listings endpoint
#
class CrudServiceDescriber
  constructor: (@root, @dataProvider, @timeout = 1000) ->

  execute: =>
    dataProvider = @dataProvider
    root = @root
    itemId = null

    describe "/services/#{root}", ->
      beforeEach -> @addMatchers(httpMatchers)
      awaitResponse = -> waitsFor(runner.isComplete, "should complete", @timeout)
      shouldHaveHttpResponse = (code) -> (err, res, body) -> expect(res).toHaveHttpResponseCode(code)

      it "GET retrieves a list of entities", ->
        runner.get "#{root}", (err, res, body) ->
          expect(res).toHaveHttpResponseCode(200)
          expect(body).toBeValidListResponse()
        awaitResponse()

      it "POST creates a new entity", ->
        runner.post "#{root}", dataProvider.newEntity, (err, res, body) ->
          expect(res).toHaveHttpResponseCode(200)
          expect(body).toMatchPayload(dataProvider.newEntity)
          itemId = dataProvider.extractId(body)
        awaitResponse()

      describe "/services/#{root}/{id}", ->
        it "GET can retrieve a known item", ->
          runner.get "#{root}/#{itemId}", (err, res, body) ->
            expect(res).toHaveHttpResponseCode(200)
            expect(body).toMatchPayload(dataProvider.newEntity)
          awaitResponse()

        it "GET with an unknown ID emits an HTTP 404 error", ->
          runner.get "#{root}/#{dataProvider.unknownId}", shouldHaveHttpResponse(404)
          awaitResponse()

        it "GET with an illegal ID emits an HTTP 400 error", ->
          runner.get "#{root}/#{dataProvider.illegalId}", shouldHaveHttpResponse(400)
          awaitResponse()

        it "PUT can update a specific known item", ->
          runner.put "#{root}/#{itemId}", dataProvider.updateEntity, (err, res, body) ->
            expect(res).toHaveHttpResponseCode(200)
            expect(body).toMatchPayload(dataProvider.updateEntity)
          awaitResponse()

        it "PUT with an unknown ID emits an HTTP 404 error", ->
          runner.put "#{root}/#{dataProvider.unknownId}", dataProvider.updateEntity, shouldHaveHttpResponse(404)

        it "PUT with an illegal ID emits an HTTP 400 error", ->
          runner.put "#{root}/#{dataProvider.illegalId}", dataProvider.updateEntity, shouldHaveHttpResponse(400)
          awaitResponse()

        it "DELETE can delete a known entity", ->
          runner.delete "#{root}/#{itemId}", shouldHaveHttpResponse(204)
          awaitResponse()
          runs ->
            runner.get "#{root}/#{itemId}", shouldHaveHttpResponse(404)
            awaitResponse()

        it "DELETE with an unknown ID emits an HTTP 404 error", ->
          runner.delete "#{root}/#{dataProvider.unknownId}", shouldHaveHttpResponse(404)
          awaitResponse()

      describe "/services/#{root}/search", ->
        it "POST can retrieve search results with a given search payload", ->
          runner.post "#{root}", dataProvider.newEntity, (err, res, body) ->
            expect(res).toHaveHttpResponseCode(200)
            itemId = body._id
          awaitResponse()

          runs ->
            runner.post "#{root}/search", dataProvider.searchObject, (err, res, body) ->
              expect(res).toHaveHttpResponseCode(200)
              expect(body).toBeValidListResponse()
              expect(body.items.length).toBeGreaterThan(0)
            awaitResponse()

module.exports = CrudServiceDescriber