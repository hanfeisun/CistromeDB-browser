dcApp = angular.module("dcApp")
services = angular.module("dcApp.services", ["dcApp"])

services.factory "filterService", ($http, root) ->
    filterSentData = undefined
    url = root + "/dc/main_filter_ng"
    doRequest = ->
      $http
        method: "GET"
        url: url
        params: filterSentData


    return (
      request: ->
        doRequest()

      setFilterSentData: (newFilterSentData) ->
        filterSentData = newFilterSentData
        return
    )


services.factory "inspectorService", ($http, root) ->
    doRequest = (id) ->
      url = root + "/dc/inspector"
      $http
        method: "GET"
        url: url
        params:
          id: id


    getImg = (id) ->
      url = root + "/dc/conserv"
      $http.get(
        url,
        params:
          id: id
      )

    return (
      request: (id) ->
        doRequest id

      get: (id) ->
        getImg id
    )


services.factory "targetService",
  ($http, root) ->
    doRequest = (id, gene) ->
      gene = ""  unless gene
      url = root + "/dc/putative_target_ng"
      $http
        method: "GET"
        url: url
        params:
          id: id
          gene: gene


    return request: (id, gene) ->
      doRequest id, gene


services.factory "motifService", ($http, root) ->
    doRequest = (id, gene) ->
      gene = ""  unless gene
      url = root + "/dc/motif_ng"
      $http
        method: "POST"
        url: url
        params:
          id: id
          gene: gene


    return request: (id, gene) ->
      doRequest id, gene

services.factory "similarService", ($http, root) ->
    doRequest = (id) ->
      url = root + "/dc/similarity"
      $http
        method: "GET"
        url: url
        params:
          id: id

    return request: (id) ->
      doRequest id

services.factory "loginService", ($http, root) ->
    doRequest = ->
      url = root + "/dc/accounts/check"
      $http
        method: "GET"
        url: url


    return request: ->
      doRequest()

