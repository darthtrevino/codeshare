module.exports = function (config) {

    function coffeeRemap(file, outputLocation, remapBase) {
        var fullLocation,
            relativeLoc = file.replace(remapBase, outputLocation);

        fullLocation = relativeLoc;
        fullLocation = fullLocation.replace(/\.coffee$/, '.js');
        return fullLocation;
    }

    config.set({

        // base path, that will be used to resolve files and exclude
        basePath: '',


        // frameworks to use
        frameworks: ['jasmine', 'requirejs'],


        // list of files / patterns to load in the browser
        files: [
            'bower_components/jquery/jquery.js',
            'bower_components/angular/angular.js',
            'bower_components/angular-mocks/angular-mocks.js',
            'bower_components/angular-cookies/angular-cookies.js',
            'bower_components/angular-ui-router/release/angular-ui-router.js',
            'bower_components/underscore/underscore-min.js',
//            'bower_components/lodash/dist/lodash.underscore.js',
            'bower_components/restangular/dist/restangular.js',
            {pattern: "client/src/**/*.coffee", included: false, served: true},
            {pattern: "client/spec/js/util/*.coffee", included: true, served: true},
            {pattern: "client/spec/js/**/*.coffee", included: false, served: true},
            'client/static/partials/**/*.html',
            'client/spec/js/main-test.js'
        ],



        preprocessors: {
            'client/src/**/*.coffee': ['coffee_client'],
            'client/spec/**/*.coffee': ['coffee_spec'],
            'client/static/partials/**/*.html': 'ng-html2js'
        },

        coffeePreprocessor: {
            // options passed to the coffee compiler
            options: {
                bare: false,
                sourceMap: true
            }
        },

        customPreprocessors: {
            coffee_spec: {
                base: 'coffee',
                transformPath: function (file) {
                    return coffeeRemap(file, '/target/client_spec/', '/client/spec/');
                }
            },
            coffee_client: {
                base: 'coffee',
                transformPath: function (file) {
                    return coffeeRemap(file, '/target/public/', '/client/src/');
                }

            }
        },

        ngHtml2JsPreprocessor: {
            stripPrefix: 'client/static/partials/',
            prependPrefix: '../../',
            moduleName: 'templates'
        },

        // list of files to exclude
        exclude: [
            'target/public/js/main.js'
        ],


        // test results reporter to use
        // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
        reporters: ['progress'],


        // web server port
        port: 9876,


        // enable / disable colors in the output (reporters and logs)
        colors: true,


        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,


        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        // Start these browsers, currently available:
        // - Chrome
        // - ChromeCanary
        // - Firefox
        // - Opera
        // - Safari (only Mac)
        // - PhantomJS
        // - IE (only Windows)
        browsers: ['PhantomJS'],


        // If browser does not capture in given timeout [ms], kill it
        captureTimeout: 60000,


        // Continuous Integration mode
        // if true, it capture browsers, run tests and exit
        singleRun: false
    });
};
