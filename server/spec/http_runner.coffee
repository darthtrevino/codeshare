request = require('request')

ROOT = "http://localhost:9000/services"

#
# Creates a fully qualified URL given a path
#
makeUrl = (path) -> "#{ROOT}/#{path}"

class HttpRunner
  completingCallback: (callback) =>
    @complete = false
    (err, res, body) =>
      callback(err, res, body)
      @complete = true

  makeOptions = (path, options={}) ->
    result =
      uri: makeUrl(path)
      timeout: 1000
      headers: { 'Accept': 'application/json' }

    for k,v of options
      result[k] = v
    result

  #
  # Performs an HTTP GET on the given path.
  #
  get: (path, callback) =>
    options = makeOptions(path)
    request.get(options, @completingCallback(callback))

  #
  # Performs an HTTP POST on the given path
  #
  post: (path, entity, callback) =>
    options = makeOptions(path, {json: entity})
    request.post(options, @completingCallback(callback))

  #
  # Performs an HTTP DELETE on the given path
  #
  delete: (path, callback) =>
    options = makeOptions(path)
    request.del(options, @completingCallback(callback))

  #
  # Performs an HTTP PUT on the given path
  #
  put: (path, entity, callback) =>
    options = makeOptions(path, {json: entity})
    request.put(options, @completingCallback(callback))

  #
  # Determines whether the current operation is complete
  #
  isComplete: => @complete

module.exports = HttpRunner