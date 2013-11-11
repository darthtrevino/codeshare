module.exports = function (config) {

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
            {pattern: "target/public/js/**/*.js", included: false},
            {pattern: "target/public/js/**/*.map", included: false},
            {pattern: "target/spec/js/ng/**/*", included: false},
            {pattern: "target/spec/js/**/*.map", included: false},
            'target/public/partials/**/*.html',
            'target/public/js/app.js',
            'target/spec/js/main-test.js'
        ],

        preprocessors: {
//            'client/**/*.coffee': ['coffee'],
            'target/public/partials/**/*.html': 'ng-html2js'
        },

        ngHtml2JsPreprocessor: {
            stripPrefix: 'target/public/partials/',
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
        browsers: ['Chrome', 'Firefox', 'PhantomJS', 'Safari'],


        // If browser does not capture in given timeout [ms], kill it
        captureTimeout: 60000,


        // Continuous Integration mode
        // if true, it capture browsers, run tests and exit
        singleRun: false
    });
};
