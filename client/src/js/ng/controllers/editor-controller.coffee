define [
  './module'
], (module) ->
  module.controller('EditorController', [
    '$scope',
    ($scope) ->
      $scope.compile = ->

        console.log "COMPILE THAT SHIT"

      $scope.aceChanged = (text) ->
        console.log "TEXT: ", text
  ])