fs = require 'fs'
xml2js = require 'xml2js'
moment = require 'moment'
MochaXUnitTestCase = require './mocha_xunit_test_case'

class MochaXUnitTestSuite
  constructor: (@fileName) ->
    matches = /\/([A-z0-9_\-]+)\.xml$/.exec @fileName
    @name = matches[1]

  fillData = (data) ->
    @totalTests = parseInt data.$.tests, 10
    @failures = parseInt data.$.failures, 10
    @skipped = parseInt data.$.skipped, 10
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

  countPercents = () ->
    if @totalTests == 0
      @percents = { failures: 0, skipped: 0, success: 0 }
      return

    @percents =
      failures: @failures * 100 / @totalTests
      skipped: @skipped * 100 / @totalTests
      success: @success * 100 / @totalTests

  parse: (callback) ->
    me = @

    fs.readFile me.fileName, (error, data) ->
      if error then return callback error, me

      xml2js.parseString data, (error, d) ->
        if error then return callback error, me

        if d == null
          return callback 'Wrong XML file'

        fillData.call me, d.testsuite
        countPercents.call me

        callback null, me

module.exports = MochaXUnitTestSuite