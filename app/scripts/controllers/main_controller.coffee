'use strict'

###*
 # @ngdoc function
 # @name dcApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the dcApp
###

dcApp = angular.module("dcApp")

dcApp.controller "ModalInstanceCtrl", ($scope, $modalInstance, modaldata) ->
  $scope.modaldata = modaldata;

  $scope.cancel = ->
    $modalInstance.dismiss('cancel');
  return


dcApp.controller "VideoCtrl", ($sce) ->
  this.config = 
    autoHide: false
    autoHideTime: 3000
    autoPlay: false  
    sources: [
      src:$sce.trustAsResourceUrl "http://cistrome.org/~qqin/cistromedb.mp4"
      type: "video/mp4"      
    ]
    theme: "bower_components/videogular-themes-default/videogular.css"
    
  return

dcApp.controller "filterController",
  ($scope, $sce, $window, filterService, inspectorService, targetService, motifService, loginService, blockUI, similarService, ngToast, $modal, root, root2) ->
    filterSentData =
      species: "all"
      cellinfos: "all"
      factors: "all"
      run: false
      curated: false
      completed: false
      keyword: ""
      clicked: null
      page: 1

    inspectorRowSelected = -1
    filterRowSelected =
      species: -1
      cellinfos: -1
      factors: -1

    downstreamFilterMap =
      keyword: [
        "species"
        "cellinfos"
        "factors"
        "page"
      ]
      run: [
        "species"
        "cellinfos"
        "factors"
        "page"
      ]
      completed: [
        "species"
        "cellinfos"
        "factors"
        "page"
      ]
      curated: [
        "species"
        "cellinfos"
        "factors"
        "page"
      ]      
      species: [
        "cellinfos"
        "factors"
        "page"
      ]
      cellinfos: [
        "factors"
        "page"
      ]
      factors: ["page"]

    mygeneMap =
      "Mus musculus": "mouse"
      "Homo sapiens": "human"

    defaultValueMap =
      species: "all"
      cellinfos: "all"
      factors: "all"
      page: 1

    genomeMap =
      "Mus musculus": "mm10"
      "Homo sapiens": "hg38"

    filterAjaxUpdate = (sent, updateFields) ->
      filterService.setFilterSentData sent
      u = updateFields
      if updateFields
        i = 0

        while i < updateFields.length
          filterSentData[updateFields[i]] = defaultValueMap[updateFields[i]]
          filterRowSelected[updateFields[i]] = -1
          i++

      # Set downstream fields to "all" before querying
      blockUI.start()

      # Let's block!
      filterService.request().success((msg, status) ->
        if updateFields
          i = 0

          while i < updateFields.length
            $scope[updateFields[i]] = msg[updateFields[i]]
            i++

        # Update downstream fields
        $scope.datasets = msg.datasets
        $scope.num_pages = msg.num_pages
        $scope.request_page = msg.request_page
        $scope.current_page = msg.request_page
        inspectorRowSelected = -1
        blockUI.stop()

        return
      ).error ->
        blockUI.stop()
        $scope.showToast(0)
        return
      return

    checkLogin = ->
      loginService.request().success (msg, status) ->
        if msg.status is "login"
          $scope.login_text = "LOGOUT " + msg.username
          $scope.login_url = "http://cistrome.org/dc/accounts/logout"
        else
          $scope.login_text = "LOGIN"
          $scope.login_url = "http://cistrome.org/dc/accounts/login"
        return

      return

    initialize = ->
      $scope.login_text = "LOGIN"
      $scope.login_url = "http://cistrome.org/dc/accounts/login"
      filterAjaxUpdate filterSentData, [
        "species"
        "cellinfos"
        "factors"
      ]
      # checkLogin()
      $scope.inspectorHidden = true
      $scope.toolHidden = true

      $scope.run = false
      $scope.completed = false
      $scope.curated = false
      $scope.datasetIDHidden = true

      $scope.factorFirst = false
      if typeof($window.sharedData) == "undefined"
        console.log ;
      else
        $scope.setInspector $window.sharedData
      return

    $scope.pageInRange = ->
      p = parseInt($scope.request_page)
      (p <= $scope.num_pages) and (p > 0)

    $scope.pageCanNext = ->
      parseInt($scope.current_page) + 1 <= $scope.num_pages

    $scope.pageCanPrev = ->
      parseInt($scope.current_page) - 1 > 0

    $scope.toggleFilterOrder = ->
      $scope.factorFirst = not $scope.factorFirst
      if $scope.factorFirst
        downstreamFilterMap["factors"] = [
          "cellinfos"
          "page"
        ]
        $scope.setFilter "cellinfos", defaultValueMap["cellinfos"]
        downstreamFilterMap["cellinfos"] = ["page"]
      else
        downstreamFilterMap["cellinfos"] = [
          "factors"
          "page"
        ]
        $scope.setFilter "factors", defaultValueMap["factors"]
        downstreamFilterMap["factors"] = ["page"]
      return

    $scope.send_bw = ->
      $("#bw_sender").submit()
      return

    $scope.send_bed = ->
      $("#bed_sender").submit()
      return

    $scope.setFilter = (key, content) ->
      filterSentData[key] = content
      $scope.inspectorHidden = true
      $scope.keyword = content  if key is "keyword"
      filterAjaxUpdate filterSentData, downstreamFilterMap[key]
      return

    $scope.toggleRunData = ->
      $scope.run = not $scope.run
      $scope.setFilter "run", $scope.run
      return

    $scope.toggleCuratedData = ->
      $scope.curated = not $scope.curated
      $scope.setFilter "curated", $scope.curated
      return

    $scope.toggleCompletedData = ->
      $scope.completed = not $scope.completed
      $scope.setFilter "completed", $scope.completed      

    $scope.selectFilterRow = (key, index) ->
      filterRowSelected[key] = index
      return

    $scope.selectedFilterRow = (key) ->
      filterRowSelected[key]

    $scope.selectInspectorRow = (index) ->
      inspectorRowSelected = index
      return

    $scope.selectedInspectorRow = ->
      inspectorRowSelected

    $scope.setTarget = (gene) ->
      if gene['title'] != undefined
        genes = gene.title
      else 
        genes = gene
      blockUI.start()
      targetService.request($scope.id, genes).success((msg, status) ->
        if gene is ""
          $scope.targetsAll = msg
        else
          $scope.targets = msg
          ##$scope.$broadcast('angucomplete-alt:clearInput', 'ex1');
        blockUI.stop()
        return
      ).error ->
        blockUI.stop()
        $scope.showToast(0)
        return
      return

    $scope.setSimilar = (id) ->
      blockUI.start()
      similarService.request(id).success((msg, status) ->
        $scope.similars = msg
        $scope.predicate = 'score' # sort
        blockUI.stop()
        return
      ).error ->
        blockUI.stop()
        $scope.showToast(0)
        return

      return

    # $scope.open = (id, size)->
    #   modalIns = $modal.open(
    #     templateUrl: "dcModal.html"
    #     controller: "ModalInstanceCtrl"
    #     size: size
    #     resolve:
    #       modaldata: ->
    #         return $scope.moaldata;
    #   )
    #   #      modalIns.result.then();
    #   return

    #scope.setMoal = (id, size) ->
      # blockUI.start()
      # inspectorService.request(id).success((msg, status) ->
      #   $scope.moaldata = msg
      #   $window.open "http://cistrome.org/db","_blank"
      #   blockUI.stop()
      #   # $scope.open id, size
      #   return
      # ).error ->
      #   $scope.showToast 0
      #   blockUI.stop()
      #   return
      # return

    $scope.setWindow = (id) ->
      win = $window.open "/db", "_blank"
      win.sharedData = id
      return

    $scope.showToast = (status) ->
      content = [
        'loading failure'
        'loading successfully'
      ]
      TYPE = [
        'warning'
        'success'
      ]
      ngToast.create(
        content: content[status]
        class: TYPE[status]
        dismissOnTimeout: true
        #timeout: 800
        dismissButton: true
        dismissOnClick: true
      )
      return

      
    $scope.setMotifHtml = (id) ->
      $scope.currentMotifUrl = $sce.trustAsResourceUrl(root2 + "/motif_html/" + id + "/table.html");
      $scope.currentLogo = ""
      return
#      $scope.currentMotifUrl = $sce.trustAsResourceUrl(root + "/motif_html/" + id + "/mdseqpos_index.html");

#    $scope.setMotif = (id, gene) ->
#      return  if id is $scope.id and not gene
#      blockUI.start()
#      motifService.request(id, gene).success((data, status) ->
#        $scope.motifs = data
#        blockUI.stop()
#        return
#      ).error ->
#        blockUI.stop()
#        $scope.showToast(0)
#      return

    $scope.setInspector = (id) ->
      blockUI.start()
      inspectorService.request(id).success((msg, status) ->
        $scope.inspectorHidden = false
        $scope.datasetHead = msg.treats[0]
        $scope.table = msg.qc.table
        $scope.inspector = msg
        console.log $scope.inspector.qc.judge.fastqc
        $scope.id = id
        $scope.targetsAll = []
        $scope.targets = []
        $scope.qcTable = $sce.trustAsHtml(msg.qcTable)
        $scope.mygeneSpecies = mygeneMap[$scope.datasetHead.species__name]
        $scope.washuGenome = genomeMap[$scope.datasetHead.species__name]
        $scope.ucscGenome = genomeMap[$scope.datasetHead.species__name]
        unless msg.status in ["completed", "run"]
          $scope.toolHidden = true
          $scope.columnCnt = 1
        else
          $scope.toolHidden = false
          $("#toolTab a:first").tab "show"
          $scope.columnCnt = msg.qc.table.treat_number + msg.qc.table.control_number

        blockUI.stop()
        return
      ).error ->
        $scope.showToast(0)
        blockUI.stop()
        return
      console.log $scope.id
      inspectorService.get id
      return id

    initialize()


dcApp.directive "dcTooltip", ->
  (scope, element, attr) ->
    element.on "mouseover", (e) ->
      element.tooltip "show"
      return

    return

dcApp.directive "dcTab", ->
  (scope, element, attr) ->
    element.on "click", (e) ->
      e.preventDefault()
      element.tab "show"
      return
    return

dcApp.filter "bioSource", ->
  bioSourceFilter = (d) ->
    bioSource = []
    bioKeys = [
      "cell_line__name"
      "cell_type__name"
      "cell_pop__name"
      "strain__name"
      "tissue_type__name"
    ]
    i = 0

    while i < bioKeys.length
      bioSource.push d[bioKeys[i]]  if d[bioKeys[i]]
      i++
    bioSource.join "; "
  bioSourceFilter

dcApp.filter "datasetMeta", ->
  bioSourceFilter = (d) ->
    bioSource = []
    bioKeys = [
      "cell_line__name"
      "cell_type__name"
      "cell_pop__name"
      "strain__name"
      "tissue_type__name"
    ]
    i = 0

    while i < bioKeys.length - 1
      bioSource.push d[bioKeys[i]]  if d[bioKeys[i]]
      i++
    bioSource.join "; "

  bioSourceFilter

dcApp.filter "motifZscore", ->
  transZscore = (input) ->
    score = input.toFixed(0)
    score

  transZscore

dcApp.filter "escape", ->
  escape = (d) ->
    encodeURI d

  escape

