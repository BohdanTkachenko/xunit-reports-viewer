fs = require 'fs'
xml2js = require 'xml2js'
XUnitTestSuite = require './mocha_xunit_test_suite'

class XUnitXML
  constructor: (@fileName) ->
    matches = /\/([A-z0-9_\-]+)\.xml$/.exec @fileName
    @name = matches[1]

  getSuits: (callback) ->
    callback = if typeof callback == 'function' then callback else () ->
    name = @name

    fs.readFile @fileName, (error, data) ->
      if error then return callback error, data

      xml2js.parseString data, (error, d) ->
        if error then return callback error, d

        if d == null
          return callback 'Wrong XML file'

        if d.testsuites then d = d.testsuites

        callback null, d.testsuite.map (testSuiteData) ->
          new XUnitTestSuite testSuiteData, name

module.exports = XUnitXML