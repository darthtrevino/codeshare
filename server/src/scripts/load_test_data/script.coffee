fs = require('fs')
Q = require('q')
_ = require('underscore')
async = require('async')
ModelIndex = require('../../models')
mongooseQ = ModelIndex.mongooseQ
Models = ModelIndex.Models

String::endsWith = (suffix) -> @indexOf(suffix, @length - suffix.length) != -1
String::startsWith = (s) -> @indexOf(s) == 0

#
# Emits an error handling method that uses the given error message
#
printError = (message) -> (err) -> console.log "******ERROR: #{message}", err

#
# A class for an import directive
#
class ImportDirective
  constructor: (@modelName, @criteria) ->
    @Model = Models[modelName]

#
# The default mongoose update options
#
updateOptions = { safe: true, upsert: true }

daysFromNow = (offset) ->
  result = new Date()
  result.setDate(result.getDate() + offset)
  result

dataTemplateDirective =
  daysAgo: (n) -> daysFromNow(-1 * n)
  daysFromNow: daysFromNow

  now: daysFromNow(0)
  yesterday: daysFromNow(-1)
  tomorrow: daysFromNow(2)
  inOneWeek: daysFromNow(7)
  inTwoWeeks: daysFromNow(14)
  oneWeekAgo: daysFromNow(-7)
  twoWeeksAgo: daysFromNow(-14)

#
# the models here are ordered based on dependency. models with dependencies appear later
#
topologicallySortedModels = [
  'Image'
  'Role'
  'MaterialsCategory'
  'Address'
  'User'
  'Notification'
  'Listing'
]

modelData = []
for dirName in topologicallySortedModels
  if !dirName.endsWith('js')
    dataDir = "#{__dirname}/#{dirName}"
    Model = Models[dirName]
    dataFiles = fs.readdirSync(dataDir)
    modelData.push { dataDir: dataDir, dataFiles: dataFiles, modelName: dirName, Model: Model }

processTemplate = (text, directive) ->
  try
    _.template(text, directive)
  catch err
    console.log "***********Error processing template", err
    null

processObjectTemplate = (object, directive) ->
  try
    text = JSON.stringify(object)
    processed = processTemplate(text, directive)
    JSON.parse(processed)
  catch err
    console.log "*********Error processing Object Template", err
    null

#
# Processes an import directive; emits a promise that provides an ObjectID
#
findModelsThatMatchDirective = (directive) ->
  directive.Model.findQ(directive.criteria)

#
# Determines whether a value is an import reference
#
isImportDirective = (v) -> typeof(v) == 'string' and v.startsWith("::IMPORT")

#
# Determines whether the input is an import reference list
#
isImportDirectiveList = (v) -> v instanceof Array and v.length > 0 and isImportDirective(v[0])

#
# Parses an Import Directive string into an Object
#
parseImportDirective = (text) ->
  parts = text.split("|")
  model = parts[1]
  criteria = parts[2]
  try
    new ImportDirective(model, JSON.parse(criteria))
  catch err
    console.log "eror parsing import directive\n\ttext=\"#{text}\"\n\tcriteria: \"#{criteria}\"", err

#
# Provides a promise to process an import directive
#
processImportDirective = (directive, handleResult) ->
  Q.when(findModelsThatMatchDirective(directive))
   .then((results) -> handleResult(results[0]))

#
# Handles an import directive property
#
handleImportDirectiveProperty = (dataObject, directive, key) ->
  handleResult = (r) -> dataObject[key] = r._id
  processImportDirective(directive, handleResult)

#
# Handles a list of import directives
#
handleImportDirectiveList = (dataObject, key) ->
  newArray = []
  promises = []
  for item in dataObject[key]
    handleResult = (r) -> newArray.push(r._id)
    promises.push processImportDirective(parseImportDirective(item), handleResult)

  dataObject[key] = newArray
  promises

#
# Handles data-import directives on a given object. The returned promise returns a populated data object
#
performDataImports = (dataObject) ->
  promises = []
  for k,v of dataObject
    if isImportDirective(v)
      promise = handleImportDirectiveProperty(dataObject, parseImportDirective(v), k)
      promises.push(promise)

    if isImportDirectiveList(v)
      importPromises = handleImportDirectiveList(dataObject, k)
      promises = promises.concat(importPromises)

  Q.all(promises).then(-> dataObject)

#
# Given a Data-File, emits a promise that provides the Model instance for the datadfile
#
createModelFromDataFile = (dataFile, datum) ->
  dataObject = processObjectTemplate(require("#{datum.dataDir}/#{dataFile}"), dataTemplateDirective)
  createModelInstance = (result) -> new datum.Model(result)
  performDataImports(dataObject).then(createModelInstance)

#
# Provides a promise to process a data file
#
processDataFile = (dataFile, datum) ->
  console.log "   #{dataFile}"
  saveModelInstance = (model) -> model.saveQ().fail(printError("problem saving [#{dataFile}]"))
  createModelFromDataFile(dataFile, datum).then(saveModelInstance)

#
# Clears out a model's instances
#
clearModel = (datum) ->
  datum.Model.removeQ({}).fail(printError("clearing model #{datum.modelName}"))

#
# A promise to load data files
#
loadDataFiles = (datum) ->
  console.log "#{datum.modelName}:"
  Q.all(datum.dataFiles.map((file) -> processDataFile(file, datum)))

#
# Provides a promise to process documents for a given medel
#
processModel = (datum) -> clearModel(datum).then( -> loadDataFiles(datum))

#
# Provides a promise to ingest the source documents
#
ingestDocuments = -> modelData.map(processModel)


#
# Provides a promise to bind user addresses
#
bindAllUserAddresses = ->
  defered = Q.defer()
  Models.User.find({}, (err, users) ->
    promises = users.map (user) -> bindAddressesForUser(user)
    defered.resolve(Q.all(promises))
  )
  defered.promise


console.log "=========Ingesting Documents==========="
Q.allSettled(ingestDocuments())
 .then(-> console.log "\n==========Ingest Complete=========")
 .then(-> process.exit())
 .done()