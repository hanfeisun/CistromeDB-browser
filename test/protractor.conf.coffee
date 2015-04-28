exports.config =
  seleniumServerJar: ''
  chromeDriver: ''
  capabilities:
    'browserName': 'chrome'
    "chromeOptions":
      args: []
      extensions: []
  specs: ['**/test.coffee']
  getPageTimeout: 60000
  allScriptsTimeout: 1200000
  onPrepare: ->
    browser.manage().window().setSize(1600, 1400)
  jasminNodeOpts:
    showColors: true,
    defaultTimeoutInterval: 12000000
  baseUrl: 'http://localhost:9001',
  framework: 'jasmine'

