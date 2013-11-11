#
# Angular Routes
#
define [
  './appmodule'
], (appModule) ->

  appModule.config(($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise('/home')

    $stateProvider
      .state 'home',
        url: '/home'
        templateUrl: 'partials/home.html'
    )

  console.info "Ng-Routes Loaded"
