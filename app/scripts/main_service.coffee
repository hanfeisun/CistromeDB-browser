dcApp = angular.module("dcApp")
services = angular.module("dcApp.services", ["dcApp"])

services.factory "filterService", ($http, root) ->
    filterSentData = undefined
    url = root + "/main_filter_ng"
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
      url = root + "/inspector"
      $http
        method: "GET"
        url: url
        params:
          id: id


    getImg = (id) ->
      url = root + "/conserv"
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
      url = root + "/putative_target_ng"
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
      url = root + "/motif_ng"
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
      url = root + "/similarity"
      $http
        method: "GET"
        url: url
        params:
          id: id

    return request: (id) ->
      doRequest id

services.factory "loginService", ($http, root) ->
    doRequest = ->
      url = root + "/accounts/check"
      $http
        method: "GET"
        url: url


    return request: ->
      doRequest()


services.factory "batchdc", (localStorageService)->
  return localStorageService.get 'batchdc'


