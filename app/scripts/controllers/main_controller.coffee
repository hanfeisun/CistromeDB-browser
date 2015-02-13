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


dcApp.controller "filterController",
  ($scope, $sce, filterService, inspectorService, targetService, motifService, loginService, blockUI, similarService, ngToast, $modal) ->
    filterSentData =
      species: "all"
      cellinfos: "all"
      factors: "all"
      hideincomplete: false
      hideunvalidated: true
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
      hideincomplete: [
        "species"
        "cellinfos"
        "factors"
        "page"
      ]
      hideunvalidated: [
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
      checkLogin()
      $scope.inspectorHidden = true
      $scope.toolHidden = true
      $scope.incompleteHidden = false
      $scope.datasetIDHidden = true
      $scope.unvalidatedHidden = true
      $scope.factorFirst = false
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

    $scope.toggleIncompleteData = ->
      $scope.incompleteHidden = not $scope.incompleteHidden
      $scope.setFilter "hideincomplete", $scope.incompleteHidden
      return

    $scope.toggleUnvalidatedData = ->
      $scope.unvalidatedHidden = not $scope.unvalidatedHidden
      $scope.setFilter "hideunvalidated", $scope.unvalidatedHidden
      return

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

    $scope.setTarget = (id, gene) ->
      return  if id is $scope.id and not gene
      blockUI.start()
      targetService.request(id, gene).success (msg, status) ->
        $scope.targets = msg
        blockUI.stop()
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

    $scope.open = (id, size)->
      modalIns = $modal.open(
        templateUrl: "dcModal.html"
        controller: "ModalInstanceCtrl"
        size: size
        resolve:
          modaldata: ->
            return $scope.moaldata;
      )
      #      modalIns.result.then();
      return

    $scope.setMoal = (id, size) ->
      blockUI.start()
      inspectorService.request(id).success((msg, status) ->
        $scope.moaldata = msg

        blockUI.stop()

        $scope.open id, size
        return
      ).error ->
        $scope.showToast 0
        blockUI.stop()
        return
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

    $scope.setMotif = (id, gene) ->
      return  if id is $scope.id and not gene
      blockUI.start()
      motifService.request(id, gene).success((data, status) ->
        $scope.motifs = data
        blockUI.stop()
        return
      ).error ->
        blockUI.stop()
        $scope.showToast(0)
      return

    $scope.setInspector = (id) ->
      blockUI.start()
      inspectorService.request(id).success((msg, status) ->
        $scope.inspectorHidden = false
        $scope.datasetHead = msg.treats[0]
        $scope.table = msg.qc.table
        $scope.inspector = msg
        $scope.qcTable = $sce.trustAsHtml(msg.qcTable)
        $scope.mygeneSpecies = mygeneMap[$scope.datasetHead.species__name]
        $scope.washuGenome = genomeMap[$scope.datasetHead.species__name]
        $scope.ucscGenome = genomeMap[$scope.datasetHead.species__name]
        unless msg.status is "complete"
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

      inspectorService.get id
      return

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

