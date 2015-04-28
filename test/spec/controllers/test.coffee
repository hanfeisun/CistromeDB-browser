fs = require 'fs'

writeScreen = (data, filename) ->
  stream = fs.createWriteStream filename
  stream.write(new Buffer data, 'base64')
  stream.end()
  return

describe 'Controller: TestCtrl', ->

  beforeEach ->
    browser.get '/'

  # it 'should redirect to different navigator', ->
  #   browser.get '/#/test'
  #   element `by`.model 'firstName'
  #     .sendKeys 'qinq'
  #   greeting = element `by`.binding 'firstName'
  #   expect greeting.getText()
  #     .toEqual 'Hello qinq'
  #   $('.navbar-brand').click()
  #   browser.get '/#/about'

  # it 'should turn to home page', ->
  #   curUrl = browser.getCurrentUrl()
  #   browser.get '/#/'
  #   nextUrl = browser.getCurrentUrl()
  #   expect(curUrl).toEqual nextUrl


  factors = [
    'LMO2'
    'MYC'
    'H3K4me3'
    # 'TP53'
    # 'EZH2'
    # 'ESRRA'
    # 'RARA'
  ]


  elclick = (el) ->
    # browser.actions().mouseMove(el).click()
    # below fail sometimes 
    el.getLocation().then (location)->
        browser.executeScript('window.scrollTo(0, ' + (location.y) + ')');
        browser.sleep(500)
        el.click()


  describe 'test one factor with all inspector panel', ->
    it 'should get ESRRA', ->
      factor = element `by`.model 'keyword'
      factor.sendKeys 'ESRRA'
      button = element `by`.css '.button-search'


      button.click().then ->
        datasets = element.all(`by`.repeater 'dataset in datasets')
        expect(datasets.get(2).element(`by`.binding 'dataset.factor__name').getText()).toEqual 'ESRRA'
        expect(datasets.count()).toEqual 4
        
        expect(datasets.get(0).element(`by`.binding 'dataset.paper__pub_summary').getText()).toEqual 'Yan J, et al. Cell 2013'
        elclick(datasets.first())
        
        motif = element(`by`.css '.motif-a')
        elclick(motif)

        target = element(`by`.css '.target-a')
        elclick(target)

        similar = element(`by`.css '.similar-a')
        elclick(similar)

        quality = element(`by`.css '.quality-a')
        elclick(quality)

        peak = element(`by`.css '.peak-a')
        elclick(peak)
        

  describe 'test all factor view by click them one by one and all inspector view', ->
    it 'should list top 5 factors', ->
      for i in [1..2]
        factor = element.all(`by`.repeater 'factor in factors').get i
        elclick(factor)
        datasets = element.all(`by`.repeater 'dataset in datasets')
        elclick(datasets.first())
        
        motif = element(`by`.css '.motif-a')
        elclick(motif)

        target = element(`by`.css '.target-a')
        elclick(target)

        similar = element(`by`.css '.similar-a')
        elclick(similar)

        quality = element(`by`.css '.quality-a')
        elclick(quality)

        peak = element(`by`.css '.peak-a')
        elclick(peak)
        # browser.takeScreenshot().then (png)->
        #   writeScreen png, i.toString()+'.png'

        
  describe 'test search function for specified factors', ->
    it 'should search a panel of factors', ->
      for f in factors
        factor = element `by`.model 'keyword'
        factor.clear()
        factor.sendKeys f
        button = element `by`.css '.button-search'
        elclick(button)

        ## click on the factor view to focus on the factor
        elclick(element(`by`.id f))
        datasets = element.all(`by`.repeater 'dataset in datasets')        
        expect(datasets.get(0).element(`by`.binding 'dataset.factor__name').getText()).toEqual f
        # browser.takeScreenshot().then (png)->
        #   writeScreen png, 'exception' + f + ".png"

