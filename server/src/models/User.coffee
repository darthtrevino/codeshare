mongoose = require('mongoose')
Schema = mongoose.Schema
gravatar = require('gravatar')
bcrypt = require('bcrypt')
Q = require('Q')
SALT_WORK_FACTOR = 10

schemaObject =
  importId: Number # For Test Datasets

  login:
    type: String
    required: true
    index:
      unique: true
      dropDups: true

  email:
    type: String
    required: true
    index:
      unique: true
      dropDups: true

  firstName:
    type: String
    required: true

  lastName:
    type: String
    required: true

  #
  # bcrypt encrypted password
  #
  password: String

#
# Define the User Schema
#
schemaOptions =
  toJSON:
    virtuals: true
  toObject:
    virtuals: true
UserSchema = new Schema(schemaObject, schemaOptions)

UserSchema.pre('save', (next) ->
  user = this
  if !user.isModified('password')
    next()
  else
    genSaltQ = Q.denodeify(bcrypt.genSalt)
    hashQ = Q.denodeify(bcrypt.hash)

    genSaltQ(SALT_WORK_FACTOR)
      .then((salt) -> hashQ(salt))
      .then((hash) -> user.password = hash)
      .then(-> next())
      .fail((err) -> next(err))
      .done()
)

#
# Password Validation
#
UserSchema.methods.isValidPassword = (password) ->
  compareQ = Q.denodeify(bcrypt.compare)
  compareQ(password, this.password)

#
# Gravatar integration
#
UserSchema.virtual('avatar').get( ->
  options = {s: 200, r: 'pg', d: 'mm'}
  gravatar.url(@email, options, true)
)

#
# FullName Calculation
#
UserSchema.virtual('fullName').get( -> "#{@firstName} #{@lastName}")

module.exports = UserSchema