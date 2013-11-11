#
# A class for inspecting HTTP headers for tasks such as content-negotiation.
#
class HeaderInspector
  #
  # Creates an HTTP handler which performs assertions that the request accepts a given content type.
  # If the request does not accept the content type, then an HTTP 406 error will be emitted.
  #
  assertAcceptsHandler: (contentType) ->
    (req, res, next) ->
      if !req.accepts(contentType)
        res.status(406).send("request must accept #{contentType}")
      else
        next()

module.exports = HeaderInspector