class MochaXUnitTestCase
  constructor: (testCase) ->
    @className = testCase.$.classname || '(root)'
    @name = testCase.$.name
    @time = parseFloat testCase.$.time
    @skipped = !!testCase.$.skipped
    @failure = testCase.failure || null

    if @skipped then @type = 'info'
    else if @failure != null then @type = 'danger'
    else @type = 'success'

module.exports = MochaXUnitTestCase