#
# The default number of an items a pageable resource will emit
#
DEFAULT_LIMIT = 10

#
# The default starting index of a list resource
#
DEFAULT_OFFSET = 0

class Pager
  #
  # Creates an HTTP handler that inspects incoming paging parameters and
  # uses a default offset and limit if the are not set. The default limit will be
  # set to 10..
  #
  normalizePagingHandler: ->
    this.normalizePagingWithLimitHandler(DEFAULT_LIMIT)

  #
  # Creates an HTTP handler that inspects incoming paging parameters and
  # uses a default offset and limit if the are not set
  #
  normalizePagingWithLimitHandler: (defaultLimit) ->
    (req, res, next) ->
      query = req.query
      console.info "applying paging to query arguments"
      if not query.offset? then query.offset = DEFAULT_OFFSET
      if not query.limit? then query.limit = defaultLimit
      console.info "finished applying paging to query arguments"
      next()

module.exports = Pager


