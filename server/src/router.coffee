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

writeJavaFile = (java) ->
  fs.writeFileSync("#{__dirname}/tmp/java/Main.java", java)
  console.log "wrote out java file"

compileJava = ->
  defered = Q.defer()
  output = ""
  compile = spawn('javac', ["#{__dirname}/tmp/java/Main.java"])
  compile.stdout.on('data', (data) -> output += data)
  compile.stderr.on('data', (data) -> output += data)
  compile.stdout.on('close', -> defered.resolve(output))

  defered.promise

runJava = ->
  defered = Q.defer()
  output = ""
  run = spawn('java', ['-cp', '.', 'Main'], {cwd: "#{__dirname}/tmp/java"})
  run.stdout.on('data', (data) -> output += data)
  run.stderr.on('data', (data) -> output += data)
  run.stdout.on('end', -> defered.resolve(output))

  defered.promise

class Router
  constructor: (@app, @routeMaker, @resources) ->

  route: ->
    # The standard HTML index
    @app.get('/', @resources.Index)

    @app.post('/services/execute_java', (req, res) ->
      java = req.body.java

      payload = { java: java }
      makeTempDirs()
      writeJavaFile(java)

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
