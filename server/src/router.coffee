Q = require('q')
fs = require('fs')
exec = require('child_process').exec
spawn = require('child_process').spawn

service = (uri) -> "/services/#{uri}"

makeTempDirs = ->
  tryMakeDir = (dirName) ->
    if not fs.existsSync(dirName) then fs.mkdirSync(dirName)

  if fs.exists(__dirname + "/tmp/java")
    files = fs.readdirSync(__dirname + "/tmp/java")
    fs.unlinkSync(f) for f in files

  tryMakeDir(__dirname + "/tmp")
  tryMakeDir(__dirname + "/tmp/java")
  console.log "created temp directories"

writeJavaFiles = (tests) ->
  fs.writeFileSync("#{__dirname}/tmp/java/Tests.java", tests)
  console.log "wrote out java file"

compileJava = ->
  defered = Q.defer()
  output = ""
  compile = spawn('javac', [
    "-cp", "#{__dirname}/jars/hamcrest-core-1.3.jar:#{__dirname}/jars/junit-4.11.jar:.",
    "#{__dirname}/tmp/java/Tests.java"])
  compile.stdout.on('data', (data) -> output += data)
  compile.stderr.on('data', (data) -> output += data)
  compile.stdout.on('close', -> defered.resolve(output))

  defered.promise

runJava = ->
  defered = Q.defer()
  output = ""
  run = spawn('java', [
    '-cp', "#{__dirname}/jars/hamcrest-core-1.3.jar:#{__dirname}/jars/junit-4.11.jar:.",
    'org.junit.runner.JUnitCore',
    'Tests'
    ], {cwd: "#{__dirname}/tmp/java"})
  run.stdout.on('data', (data) -> output += data)
  run.stderr.on('data', (data) -> output += data)
  run.stdout.on('end', -> defered.resolve(output))

  defered.promise


wrapCode = (main, tests) ->
  """
  import org.junit.*;
  import static org.junit.Assert.*;
  import java.util.*;

  #{main}

  public class Tests {
  #{tests}
  }
  """

class Router
  constructor: (@app, @routeMaker, @resources) ->

  route: ->
    # The standard HTML index
    @app.get('/', @resources.Index)

    @app.post('/services/execute_java', (req, res) ->
      java = req.body.java
      tests = req.body.tests

      payload = { java: java }
      makeTempDirs()
      writeJavaFiles(wrapCode(java, tests))

      compileJava()
      .then((out) -> payload.compileOutput = out)
      .then(-> runJava())
      .then((out) -> payload.runOutput = out)
      .then(-> res.status(200).send(payload))
      .fail((err) -> res.status(500).send(err))
      .done()
    )

    # The service root
    @app.get(service('/'), @resources.Root.get)

    # Set up crud routes for top-level entities
    @routeMaker.makeCrudRoutes(service('users'), @resources.Users, "all")

module.exports = Router
