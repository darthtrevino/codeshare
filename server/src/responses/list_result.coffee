identity = (p) -> p

class ListResult
  constructor: (@payloadProcessor=identity) ->
    @items = []
    @count = 0
    @totalResultCount = 0

  addItems: (set=[]) =>
    for s in set
      @items.push(@payloadProcessor(s.toObject()))
    @count = @count + set.length

module.exports = ListResult