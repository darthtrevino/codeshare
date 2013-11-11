/**
 * This file is required for loading test files using requireJS.  It needs to be a JS file (I think)
 * in order to load as a served file in karma.
 */
(function() {
    var file, tests;

    tests = [];

    for (file in window.__karma__.files) {
        if (window.__karma__.files.hasOwnProperty(file)) {
            if (/Spec\.js$/.test(file)) {
                tests.push(file);
            }
        }
    }
    

    requirejs.config({
        baseUrl: '/base/target/public/js',
//        paths: {
//            lodash: "../../../bower_components/lodash/dist/lodash",
//            restangular: "../../../bower_components/restangular/dist/restangular"
//        },
//        shim: {
//            'restangular': {
//                deps: ['lodash']
//            }
//        },
        deps: tests,
        callback: window.__karma__.start
    });

}).call(this);
