#
# Defines the main application module
#
define [
  './filters'
  './services'
  './directives'
  './controllers'
], ->
  console.info "Creating codeshare Application Ng-Module"

  angular.module('codeshare', [
    # Angular/Third Party Modules
    'ngCookies'
    'ui.state'
    'restangular'

    # Application Modules
    'codeshare.filters'
    'codeshare.services'
    'codeshare.directives'
    'codeshare.controllers'
  ])
    .config((RestangularProvider) ->
      RestangularProvider.setBaseUrl('/services')

      # handles mongo ids
      RestangularProvider.setRestangularFields({
        id: "_id"
      })

      RestangularProvider.setResponseExtractor((response, operation) ->
        if operation == 'getList'
          return response.items

        return response
      )
  )

