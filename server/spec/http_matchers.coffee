module.exports =

  #
  # A matcher that verifies a response contains the expected HTTP status code
  #
  toHaveHttpResponseCode: (expected) ->
    if !@actual
      @message = -> "No response received"
      false
    else
      status = @actual.statusCode
      @message = -> "Expected #{expected} status code, got #{status}"
      status == expected

  #
  # A matcher that verifies that a list response is well formed.
  #
  toBeValidListResponse: ->
    @message = -> "Expected #{@actual} to be a ListResponse payload."

    if !@actual
      return false
    else
      if typeof @actual == "string"
        payload = JSON.parse(@actual)
      else
        payload = @actual
      payload and payload.count >= 0 and payload.totalResultCount >= 0 and payload.items and payload.items.length >= 0

  toMatchPayload: (expected) ->
    if !@actual
      @message = -> "payload is #{@actual}"
      false
    else
      for k,v in expected
        if @actual[k] != v
          @message = -> "expected #{k} to be #{v}; actually is #{@actual[k]}"
          return false
      true