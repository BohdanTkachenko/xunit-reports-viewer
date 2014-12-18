fs = require 'fs'
xml2js = require 'xml2js'
moment = require 'moment'
MochaXUnitTestCase = require './mocha_xunit_test_case'

class MochaXUnitTestSuite
  constructor: (@data, @fileName) ->
    @name = data.$.name or @fileName
    @totalTests = parseInt data.$.tests, 10
    @failures = parseInt data.$.failures, 10
    @skipped = (parseInt data.$.skipped, 10) or 0
    @success = @totalTests - @failures - @skipped
    @timestamp = new Date data.$.timestamp
    @timestampReadable = moment(@timestamp).format 'MM/DD/YYYY HH:mm:ss'
    @timeTotal = data.$.time
    @timeTotalReadable = moment.duration(@timeTotal * 1000).humanize()

    @classes = []
    @tests = data.testcase.map (testCase) -> new MochaXUnitTestCase testCase
    @tests.forEach (testCase) ->
      if @classes.indexOf(testCase.className) == -1
        @classes.push testCase.className
    , @

    @pockets = {}
    for className in @classes
      @pockets[className] =
        name: className
        tests: []

      for test in @tests
        if test.className is className
          @pockets[className].tests.push test

    if @totalTests == 0
      @percents = { failures: 0, skipped: 0, success: 0 }
      return

    @percents =
      failures: @failures * 100 / @totalTests
      skipped: @skipped * 100 / @totalTests
      success: @success * 100 / @totalTests

module.exports = MochaXUnitTestSuite