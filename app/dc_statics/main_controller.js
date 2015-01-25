var dcApp = angular.module("dcApp", ["dcApp.services", "blockUI", "angucomplete"])

dcApp.config(function(blockUIConfig) {
    blockUIConfig.autoBlock = false;
})

dcApp.controller("filterController", ["$scope","$sce", "filterService", 'inspectorService', "targetService", "motifService", "loginService","blockUI","similarService",
                                      function ($scope, $sce, filterService, inspectorService,  targetService, motifService, loginService, blockUI, similarService) {
        var filterSentData = {
            species: "all",
            cellinfos: "all",
            factors: "all",
            hideincomplete: false,
            hideunvalidated: true,
            keyword: "",
            clicked: null,
            page: 1
        }
        var inspectorRowSelected = -1
        var filterRowSelected = {
            species: -1,
            cellinfos: -1,
            factors: -1
        }
        var downstreamFilterMap = {

            keyword: ["species","cellinfos", "factors", "page"],
            hideincomplete:["species","cellinfos", "factors", "page" ],
            hideunvalidated: ["species","cellinfos", "factors", "page" ],
            species: ["cellinfos", "factors", "page"],
            cellinfos: ["factors","page"],
            factors: ["page"]
            }
        var mygeneMap = {
            "Mus musculus": "mouse",
            "Homo sapiens": "human"
        }

        var defaultValueMap = {
            "species": "all",
            "cellinfos": "all",
            "factors": "all",
            "page": 1
        }
        var genomeMap = {
            "Mus musculus": "mm10",
            "Homo sapiens": "hg38"
        }



        var filterAjaxUpdate = function (sent, updateFields) {
            filterService.setFilterSentData(sent)
            u = updateFields
            if(updateFields) {
                for (var i = 0; i < updateFields.length; i++) {
                    filterSentData[updateFields[i]] = defaultValueMap[updateFields[i]]
                    filterRowSelected[updateFields[i]] = -1
                }
                // Set downstream fields to "all" before querying
            }

            blockUI.start();
            // Let's block!
            filterService.request().success(function (msg, status) {
                if(updateFields) {
                    for (var i = 0; i < updateFields.length; i++) {
                        $scope[updateFields[i]] = msg[updateFields[i]]
                    }
                    // Update downstream fields
                }
                $scope.datasets = msg.datasets
                $scope.num_pages = msg.num_pages
                $scope.request_page = msg.request_page
                $scope.current_page = msg.request_page
                inspectorRowSelected = -1
                blockUI.stop();
            })
        }

        var checkLogin = function () {
            loginService.request().success(
                function (msg, status) {
                    if (msg.status == "login") {
                        $scope.login_text = "LOGOUT " + msg.username
                        $scope.login_url = "http://cistrome.org/dc/accounts/logout"
                    } else {
                        $scope.login_text = "LOGIN"
                        $scope.login_url = "http://cistrome.org/dc/accounts/login"
                    }

                }
            )


        }
        var initialize = function () {
            $scope.login_text = "LOGIN"
            $scope.login_url = "http://cistrome.org/dc/accounts/login"
            filterAjaxUpdate(filterSentData, ["species", "cellinfos", "factors"])
            checkLogin()
            $scope.inspectorHidden = true
            $scope.toolHidden = true
            $scope.incompleteHidden = false
            $scope.datasetIDHidden = true
            $scope.unvalidatedHidden = true
            $scope.factorFirst = false
        }



        $scope.pageInRange = function () {
            var p =  parseInt($scope.request_page)
            return  (p <= $scope.num_pages) && (p > 0)
        }

        $scope.pageCanNext = function () {
            return parseInt($scope.current_page) + 1 <= $scope.num_pages
        }

        $scope.pageCanPrev = function () {
            return parseInt($scope.current_page) - 1 > 0
        }


        $scope.toggleFilterOrder = function () {
            $scope.factorFirst = !$scope.factorFirst
            if ($scope.factorFirst) {
                downstreamFilterMap["factors"] = ["cellinfos",  "page"];

                $scope.setFilter("cellinfos",defaultValueMap["cellinfos"])
                downstreamFilterMap["cellinfos"] = ["page"]

            } else {
                downstreamFilterMap["cellinfos"] = ["factors","page"]
                $scope.setFilter("factors",defaultValueMap["factors"])
                downstreamFilterMap["factors"] = ["page"];

            }
        }

        $scope.send_bw = function() {
            $("#bw_sender").submit()
        }

        $scope.send_bed = function() {
            $("#bed_sender").submit()
        }



        $scope.setFilter = function (key, content) {
            filterSentData[key] = content
            $scope.inspectorHidden = true
            if(key=="keyword") {
                $scope.keyword = content
            }

            filterAjaxUpdate(filterSentData, downstreamFilterMap[key])


        }

        $scope.toggleIncompleteData = function () {
            $scope.incompleteHidden = !$scope.incompleteHidden
            $scope.setFilter("hideincomplete", $scope.incompleteHidden)
        }

        $scope.toggleUnvalidatedData = function () {
            $scope.unvalidatedHidden = !$scope.unvalidatedHidden
            $scope.setFilter("hideunvalidated", $scope.unvalidatedHidden)
        }


        $scope.selectFilterRow = function (key, index) {
            filterRowSelected[key] = index;
        }

        $scope.selectedFilterRow = function (key) {
            return filterRowSelected[key]
        }



        $scope.selectInspectorRow = function (index) {
            inspectorRowSelected = index
        }

        $scope.selectedInspectorRow = function () {
            return inspectorRowSelected
        }

        $scope.setTarget = function(id, gene) {
            if (id==$scope.id && !gene) {
                return
            }

            blockUI.start();
            targetService.request(id, gene).success(
                function (msg, status) {
                    $scope.targets = msg
                    blockUI.stop()
                }
            )
        }

        $scope.setSimilar = function(id) {
            blockUI.start();
            similarService.request(id).success(
                function (msg, status) {
                    $scope.similars= msg
                    blockUI.stop()
                }
            ).error(function(){blockUI.stop()})
        }

	$scope.setMotif = function(id, gene) {
	    if (id==$scope.id && !gene) {
		return
	    }
	    blockUI.start();

	    motifService.request(id, gene).success(
		function(data, status) {
		    $scope.motifs = data
		    blockUI.stop()
		}
	    )
	}

        $scope.setInspector = function (id) {

            blockUI.start();
            inspectorService.request(id).success(
                function (msg, status) {

                    $scope.inspectorHidden = false
                    $scope.datasetHead = msg.treats[0]
                    $scope.table = msg.qc.table

                    $scope.inspector = msg
                    $scope.qcTable = $sce.trustAsHtml(msg.qcTable)
                    $scope.mygeneSpecies = mygeneMap[$scope.datasetHead.species__name]
                    $scope.washuGenome =  genomeMap[$scope.datasetHead.species__name]
                    $scope.ucscGenome = genomeMap[$scope.datasetHead.species__name]
                    if(msg.status !="complete") {
                        $scope.toolHidden = true
                        $scope.columnCnt = 1
                    } else {
                        $scope.toolHidden = false
                        $("#toolTab a:first").tab("show")
                        $scope.columnCnt = msg.qc.table.treat_number + msg.qc.table.control_number
                    }


                    blockUI.stop();
                }
            ).error(function(){blockUI.stop()});
            inspectorService.get(id);
        }
        initialize()


    }]);

dcApp.controller("qcController",  ["$scope",
    function () {

    }])

dcApp.directive('dcTooltip',
    function() {
        return function (scope, element, attr) {
            element.on("mouseover", function(e){ element.tooltip("show")})
        }})

dcApp.directive('dcTab',
    function() {
        return function (scope, element, attr) {
            element.on("click", function(e){e.preventDefault(); element.tab("show")})
        }})

dcApp.filter("bioSource", function () {
    var bioSourceFilter = function (d) {
        var bioSource = []
        var bioKeys = ["cell_line__name", "cell_type__name", "cell_pop__name", "strain__name", "tissue_type__name"]
        for (var i = 0; i < bioKeys.length; i++) {
            if (d[bioKeys[i]])
                bioSource.push(d[bioKeys[i]])
        }
        return bioSource.join("; ")
    }
    return bioSourceFilter
})


dcApp.filter("datasetMeta", function () {
    var bioSourceFilter = function (d) {
        var bioSource = []
        var bioKeys = ["factor__name","cell_line__name", "cell_type__name", "cell_pop__name", "strain__name", "tissue_type__name", ]
        for (var i = 0; i < bioKeys.length; i++) {
            if (d[bioKeys[i]])
                bioSource.push(d[bioKeys[i]])
        }
        return bioSource.join("; ")
    }
    return bioSourceFilter
})

dcApp.filter("motifZscore", function() {
    var transZscore = function(input) {
	var score = input.toFixed(0);
	return score;
    }
    return transZscore;
})

dcApp.filter("escape", function () {
    var escape = function (d) {
        return encodeURI(d)
    }
    return escape
})
