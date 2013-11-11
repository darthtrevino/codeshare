fs = require('fs')
config = require('config').Database

# Connect Mongoose to mongodb
mongoose = require('mongoose')
mongoose.connect(config.connectionString)
mongooseQ = require('mongoose-q')(mongoose)
module.exports.mongoose = mongoose
module.exports.mongooseQ = mongooseQ

isNotIndex = (f) -> f.indexOf('index') == -1
stripExtension = (f) -> f.substring(0, f.indexOf('.'))
fileNames = fs.readdirSync(__dirname)
models = fileNames.filter(isNotIndex).map(stripExtension)

#
# Add each model as an exported property
#
module.exports.Models = {}
for model in models
  schema = require("./#{model}")
  module.exports.Models[model] = mongoose.model(model, schema)
