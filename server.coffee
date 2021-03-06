path = require 'path'
fs = require 'fs'
http = require 'http'
express = require 'express'
logger = require 'morgan'
mime = require 'mime'
async = require 'async'
XUnitXML = require './lib/xunit_xml'
MochaXUnitTestSuite = require './lib/mocha_xunit_test_suite'

module.exports = (options) ->
  app = require('express')()
  app.set 'app name', options.name || 'xunit-reports-viewer'
  app.set 'view engine', 'hbs'
  app.set 'views', path.join(__dirname, 'views')
  app.use logger 'dev'
  app.use express.static path.join(__dirname, 'public')
  app.set 'port', parseInt(options.port || 2042)

  if not options.dir
    console.log "Reports directory is not defined."
    process.exit 1

  app.set 'reports dir', options.dir

  if not fs.existsSync app.get 'reports dir'
    console.log "Reports directory '#{app.get 'reports dir'}' does not exists."
    process.exit 2
  else
    console.log "Using reports dir: #{app.get 'reports dir'}"

  app.locals.name = app.get 'app name'

  app.get '/', (req, res) ->
    res.redirect '/reports'

  app.get '/reports', (req, res, next) ->
    fs.readdir app.get('reports dir'), (error, files) ->
      if error then return next error

      files = files.filter (fileName) ->
        mime.lookup(path.join(app.get('reports dir'), fileName)) is 'application/xml'

      xmls = files.map (fileName) -> new XUnitXML app.get('reports dir') + '/' + fileName

      async.map xmls, ((xml, next) ->
        xml.getSuits (error, suit) ->
          next null, if error then null else suit
      ), (error, suits) ->
        if error then return next error

        suits = [].concat.apply [], suits

        results = suits.filter (result) -> !!result
        results = suits.sort (a, b) ->
          if a.timestamp > b.timestamp
            return 1

          if a.timestamp < b.timestamp
            return -1

          return 0

        res.render 'testSuitsList',
          list: suits

  app.get '/reports/:name', (req, res, next) ->
    reportFileName = "#{app.get 'reports dir'}/#{req.params.name}.xml"

    if not fs.existsSync reportFileName
      res.status 404
      res.end "Report '#{reportFileName}' was not found", 404
      return

    xml = new XUnitXML reportFileName
    xml.getSuits (error, suits) ->
      if error then return next error

      res.render 'testSuite',
        testSuits: suits


  http.createServer(app).listen app.get('port'), () ->
    console.log "Running server on http://localhost:#{app.get('port')} ..."
