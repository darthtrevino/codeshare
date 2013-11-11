#
# Angular Services.  Services should not be defined here, but should be included via requirejs
#
define [
  './services/module'
  './services/value_service'
], ->
  console.info "Ng-Services Loaded"