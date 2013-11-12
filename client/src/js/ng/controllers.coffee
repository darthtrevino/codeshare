#
# Angular Controllers Wiring - individual controllers should not be defined here, but should be included via requirejs
#
define [
  './controllers/module'
  './controllers/editor-controller'
], ->
  console.log "Ng-Controllers Loaded"