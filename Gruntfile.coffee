LIVERELOAD_PORT = 35729

path = require('path')

module.exports = (grunt) ->

  #
  # Print out the Production Dependencies
  #
  productionNodeDependencies = Object.keys(grunt.file.readJSON('package.json').dependencies).map((s) -> "#{s}/**/*")
  productionBowerDependencies = Object.keys(grunt.file.readJSON('bower.json').dependencies).map((s) -> "#{s}/**/*")
  grunt.log.writeln "Production Node Deps: #{productionNodeDependencies}"
  grunt.log.writeln "Production Bower Deps: #{productionBowerDependencies}"

  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  # configurable paths
  yeomanConfig =
    targetEnv: 'development'
    dist: 'dist'
    tmp: '.tmp'
    target:
      client: 'target/public'
      server: 'target'
    app: 'client'

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    yeoman: yeomanConfig

    #
    # NodeJS Web Server
    #
    express:
      options:
        port: 9000

      development:
        options:
          script: 'target/main.js'
      integration:
        options:
          script: 'target/main.js'
      production:
        options:
          script: 'target/main.js'

    copy:
      client_static:
        cwd: 'client/static'
        src: [ '**', '!**/*.less' ]
        dest: '<%= yeoman.target.client %>'
        flatten: false
        expand: true

      client_compiled:
        cwd: 'client/src'
        src: [ '**/*' ]
        dest: '<%= yeoman.target.client %>'
        flatten: false
        expand: true

      server:
        cwd: 'server/src'
        src: [ '**', '!**/*.coffee' ]
        dest: 'target'
        flatten: false
        expand: true

      config:
        src: 'config/**'
        dest: 'target'
        flatten: false
        expand: true

      bower_components:
        cwd: 'bower_components'
        src: [ '**' ]
        dest: '<%= yeoman.target.client %>/components'
        flatten: false
        expand: true

      client_spec:
        cwd: 'client/spec'
        src: [ '**/*' ]
        dest: 'target'
        flatten: false
        expand: true

      node_components:
        cwd: 'node_modules'
        src: productionNodeDependencies
        dest: 'target/node_modules'
        flatten: false
        expand: true

      package_json:
        src: './package.json'
        dest: 'target/package.json'

    #
    # Coffeescript Linting
    #
    coffeelint:
      options:
        max_line_length:
          value: 200
      app: ['client/src/**/*.coffee', 'Gruntfile.coffee']

    #
    # Coffeescript Compilation
    #
    coffee:
      server:
        cwd: 'server/src'
        src: ['**/*.coffee', '!public/**', '!spec/**' ]
        dest: 'target'
        expand: true
        flatten: false
        ext: '.js'

      client:
        cwd: '<%= yeoman.target.client %>'
        src: '**/*.coffee'
        dest: '<%= yeoman.target.client %>'
        options:
          sourceMap: true
        expand: true
        flatten: false
        sourceMap: true
        ext: '.js'

      client_test:
        cwd: 'client/spec'
        src: '**/*.coffee'
        dest: 'target/client_spec'
        options:
          sourceMap: true
        expand: true
        flatten: false
        sourceMap: true
        ext: '.js'

      server_test:
        cwd: 'server/spec'
        src: '**/*.coffee'
        dest: 'target/server_spec'
        options:
          sourceMap: true
        expand: true
        flatten: false
        sourceMap: true
        ext: '.js'


    #
    # LESS Compilation
    #
    less:
      options:
        strictImports: true

      development:
        files:
          "<%= yeoman.target.client %>/styles/codeshare.css": "<%= yeoman.app %>/static/styles/*.less"

      integration:
        files:
          "<%= yeoman.target.client %>/styles/codeshare.css": "<%= yeoman.app %>/static/styles/*.less"

      production:
        files:
          "<%= yeoman.tmp %>/styles/codeshare.css": "<%= yeoman.app %>/static/styles/*.less"
          "<%= yeoman.tmp %>/styles/bootstrap.css": "bower_components/bootstrap/less/bootstrap.less"
        yuicompress: true

      bootstrap:
        files: "<%= yeoman.target.client %>/styles/bootstrap.css": "bower_components/bootstrap/less/bootstrap.less"

    #
    # File Watching
    #
    watch:
      client_static:
        files: ['client/static/**/*.html']
        tasks: ['copy:client_static']

      client_coffee:
        files: ['client/src/**/*.coffee']
        tasks: ['copy:client_compiled', 'coffee:client']
        options:
          spawn: true
          interrupt: true

      less:
        files: ['client/static/styles/**/*.less']
        tasks: ['less-env']

      server:
        files: ['server/src/**/*.coffee']
        tasks: ['copy:server', 'coffee:server', 'bounce-server']
        options:
          nospawn: true
          interrupt: true

      config:
        files: ['config/**/*.yaml']
        tasks: ['copy:config', 'bounce-server']

      express:
        options:
          livereload: true
          nospawn: true
        files: [
          # this could probably be a **/* for the target.client?
          '<%= yeoman.target.client %>/img/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
          '<%= yeoman.target.client %>/styles/{,*/}*.css'
          '<%= yeoman.target.client %>/partials/**/*.html'
          '<%= yeoman.target.client %>/js/**/*.js'
          '!<%= yeoman.target.server %>/src/*.coffee'
          '!<%= yeoman.target.server %>/*spec/**/*.coffee'
        ]

      integration_test_server:
        files: ['server/spec/**/*.coffee']
        tasks: ['coffee:server_test', 'jasmine_node', 'process-test-reports']

    #
    # Build Cleaning
    #
    clean:
      build: ['<%= yeoman.tmp %>', 'target']
      client_spec: ['<%= yeoman.target.server %>/client_spec']

    #
    # Minification/optimazation tasks
    #
    useminPrepare:
      options:
        dest: '<%= yeoman.target %>'
      html: '<%= yeoman.target %>/index.html'

    usemin:
      options:
        dirs: ['<%= yeoman.tmp %>']
      html: ['<%= yeoman.target %>/{,*/}*.html']
      css: ['<%= yeoman.target %>/styles/{,*/}*.css']

    imagemin:
      dist:
        files: [
          {
            expand: true
            cwd: '<%= yeoman.target %>/img'
            src: '{,*/}*.{png,jpg,jpeg}'
            dest: '<%= yeoman.target %>/images'
          }
        ]

    htmlmin:
      dist:
      #options:
      #/*removeCommentsFromCDATA: true,
      # https:#github.com/yeoman/grunt-usemin/issues/44
      #collapseWhitespace: true,
      #collapseBooleanAttributes: true
      #removeAttributeQuotes: true
      #removeRedundantAttributes: true
      #useShortDoctype: true,
      #removeEmptyAttributes: true,
      #removeOptionalTags: true*/
      #},
        files: [
          expand: true
          cwd: '<%= yeoman.target %>'
          src: '*.html'
          dest: '<%= yeoman.target %>'
        ]

    autoprefixer:
      options:
        browsers: ['last 1 version']
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.target %>/styles/'
          src: '{,*/}*.css'
          dest: '<%= yeoman.target %>/styles/'
        ]

    requirejs:
      dist:
      # Options: https:#github.com/jrburke/r.js/blob/master/build/example.build.js
        options:
        # `name` and `out` is set by grunt-usemin
          baseUrl: '<%= yeoman.tmp %>/client/js'
          mainConfigFile: '<%= yeoman.tmp %>/client/js/main.js'
          optimize: 'none'
          dir: '<%= yeoman.target.client %>/js'
#          out: '<% yeoman.target %>/js/main.js'
        # TODO: Figure out how to make sourcemaps work with grunt-usemin
        # https:#github.com/yeoman/grunt-usemin/issues/30
        #generateSourceMaps: true,
        # required to support SourceMaps
        # http:#requirejs.org/docs/errors.html#sourcemapcomments
          preserveLicenseComments: false,
          useStrict: true,
          wrap: true

    #
    # Client Unit Testing
    #
    karma:
      unit:
        configFile: 'karma.conf.js'
        autoWatch: true
        browsers: ['Chrome']
      production:
        singleRun: true
        autoWatch: false
        configFile: 'karma.conf.js'
        browsers: ['PhantomJS']
      e2e:
        configFile: 'karma-e2e.conf.js'
        autoWatch: true

    open:
      server:
        path: 'http://localhost:<%= express.options.port %>'

    #
    # Server Testing
    #
    jasmine_node:
      options:
        projectRoot: 'target'
        specFolders: ['target/server_spec']
        isVerbose: true

      unit:
        options:
          specNameMatcher: '_spec'
          junitreport:
            report: true
            useDotNotation: true
            consolidate: true
            savePath: "target/reports/jasmine/unit/"

      integration:
        options:
          specNameMatcher: "_ispec"
          junitreport:
            report: true
            useDotNotation: true
            consolidate: true
            savePath: "target/reports/jasmine/integration/"

    #
    # Report Processing
    #
    xsltproc:
      server_unit_tests:
        options:
          stylesheet: 'reports/junit-report-to-html.xsl'
        files: [
          expand: true
          cwd: 'target/reports/jasmine/unit'
          src: '**/TEST-*.xml'
          dest: 'target/reports/jasmine/unit'
          ext: '.html'
        ]

      server_integration_tests:
        options:
          stylesheet: 'reports/junit-report-to-html.xsl'
        files: [
          expand: true
          cwd: 'target/reports/jasmine/integration'
          src: '**/TEST-*.xml'
          dest: 'target/reports/jasmine/integration'
          ext: '.html'
        ]

    #
    # Concatenate Test Results
    #
    concat:
      test_results:
        options:
          separator: "\n"
        src: [
          'reports/test_report_header.html'
          'reports/begin_integration_tests.html'
          'target/reports/jasmine/integration/**/*.html'
          'reports/end_test_section.html'
          'reports/begin_unit_tests.html'
          'target/reports/jasmine/unit/**/*.html'
          'reports/end_test_section.html'
          'reports/test_report_footer.html'
        ]
        dest: 'target/public/test_reports/server_test_results.html'

    #
    # Environment Bootstrapping
    #
    env:
      development:
        options:
          PHANTOMJS_BIN: './node_modules/.bin/phantomjs'
          NODE_ENV: 'development'

      integration:
        options:
          PHANTOMJS_BIN: './node_modules/.bin/phantomjs'
          NODE_ENV: 'integration'

      production:
        options:
          PHANTOMJS_BIN: './node_modules/.bin/phantomjs'
          NODE_ENV: 'production'


    #
    # Final Artifact Archiving
    #
    zip:
      application:
        cwd: 'target'
        src: [ 'target/**/*', '!target/spec/**/*' ]
        dest: 'target/app.zip'
  #
  # Task Imports
  #
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-express-server'
  grunt.loadNpmTasks 'grunt-jasmine-node'
  grunt.loadNpmTasks 'grunt-env'
  grunt.loadNpmTasks 'grunt-zip'
  grunt.loadNpmTasks 'grunt-xsltproc'

  #
  # This task is a marker task that switches the build into production mode.
  # To use this, run
  # 'grunt production <target>' or
  # 'grunt integration <target>'
  #
  grunt.registerTask 'production', -> yeomanConfig.targetEnv = 'production'
  grunt.registerTask 'integration', -> yeomanConfig.targetEnv = 'integration'


  #
  # Copies the primary componentry into the target folder
  #
  grunt.registerTask 'copyEverythingButNodeComponents', [
    'copy:client_static'
    'copy:client_compiled'
    'copy:server'
    'copy:config'
    'copy:bower_components'
    'copy:package_json'
  ]

  #
  # Less CSS Processing
  #
  grunt.registerTask 'less-env', -> grunt.task.run "less:#{yeomanConfig.targetEnv}"
  grunt.registerTask 'less-all', ['less:bootstrap', 'less-env']

  #
  # Server Management
  #
  grunt.registerTask 'set-environment', -> grunt.task.run "env:#{yeomanConfig.targetEnv}"
  grunt.registerTask 'start-server', -> grunt.task.run "express:#{yeomanConfig.targetEnv}"
  grunt.registerTask 'stop-server', -> grunt.task.run "express:#{yeomanConfig.targetEnv}:stop"
  grunt.registerTask 'bounce-server', ['stop-server', 'start-server']
  #
  # Testing Tasks
  #
  grunt.registerTask 'unit-test-client', ['copy:client_spec', 'karma:production']
  grunt.registerTask 'unit-test-client-watch', ['copy:client_spec', 'karma:unit']
  grunt.registerTask 'unit-test-server', ['jasmine_node:unit']
  grunt.registerTask 'integration-test-server', ['jasmine_node:integration']
  grunt.registerTask 'integration-test-client', []
  grunt.registerTask 'integration-test-server-watch', ['coffee:server_test', 'jasmine_node:integration', 'watch:integration_test_server']
  grunt.registerTask 'integration-test-nospawn', [ 'integration-test-server', 'integration-test-client' ]
  grunt.registerTask 'unit-test', [
    'set-environment'
    'unit-test-client'
    'unit-test-server'
  ]
  grunt.registerTask 'integration-test', [
    'set-environment'
    'start-server'
    'integration-test-nospawn'
    'stop-server'
  ]
  grunt.registerTask 'process-test-reports', [
    'xsltproc'
    'concat:test_results'
  ]
  grunt.registerTask 'test-all-nospawn', ['unit-test', 'integration-test-nospawn', 'process-test-reports']
  grunt.registerTask 'test-all', ['unit-test', 'integration-test', 'process-test-reports']
  grunt.registerTask 'test-server', [
    'set-environment'
    'unit-test-server'
    'start-server'
    'integration-test-server'
    'stop-server'
  ]
  grunt.registerTask 'run-server-tests', [
    'coffee:server'
    'coffee:server_test'
    'test-server'
  ]

  #
  # The primary build
  #
  grunt.registerTask 'build', [
    'set-environment'
    'clean'
    'coffeelint'
    'copyEverythingButNodeComponents'
    'coffee'
    'less-all'
  ]

  #
  # Builds the application and starts a running express server
  #
  grunt.registerTask 'server', [
    'build'
    'copy:node_components'
    'start-server'
    #'test-all-nospawn'
    'open'
    'watch'
  ]

  #
  # Builds the application and prepares a deployment package
  #
  grunt.registerTask 'package', ['zip']
  grunt.registerTask 'dist', [
    'build'
    'copy:node_components'
    #'test-all'
    #'useminPrepare'
    #'concurrent:dist'
    #'autoprefixer'
    #'requirejs'
    #'concat'
    #'cssmin'
    #'uglify'
    #'rev'
    #'usemin'
    'package'
  ]

  #
  # Packaging Tasks
  #
  grunt.registerTask 'default', [ 'dist' ]
  grunt.registerTask 'cloudbees', [
    'integration'
    'build'
    'copy:node_components'

    #====
    # NOTE: Karma:production is broken on cloudbees.
    # When this is fixed, we should replace the following tasks with 'test-all'
    #'unit-test-server'
    #'integration-test'
    #'test-all'
    #=====

    'package'
  ]