#
# Application Bootstrapping
#
require.config({
#  path:
#    lodash: 'components/lodash/lodash'
  shim:
    app:
      deps: [
#        'lodash'
        #place require dependencies here if necessary
      ]
})

require ['app'], (app) ->
  console.info "Bootstrapping Application"
  angular.bootstrap(document, ['codeshare'])