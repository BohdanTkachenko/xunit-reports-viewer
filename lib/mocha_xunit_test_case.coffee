Handlebars = require '../node_modules/hbs/node_modules/handlebars/lib/index'
entities = require 'entities'

class MochaXUnitTestCase
  constructor: (testCase) ->
    @className = testCase.$.classname || '(root)'
    @name = testCase.$.name
    @time = parseFloat testCase.$.time
    @skipped = !!testCase.skipped

    @failure = null
    if testCase.failure
      @failure = entities.decodeHTML testCase.failure

      @failure = new Handlebars.SafeString @failure

    if @skipped then @type = 'info'
    else if @failure != null then @type = 'danger'
    else @type = 'success'

module.exports = MochaXUnitTestCase
