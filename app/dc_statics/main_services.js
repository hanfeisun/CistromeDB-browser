var services = angular.module('dcApp.services',
    []);
services.factory("filterService", ["$http", function ($http) {
    var filterSentData;
    var doRequest = function () {
        return $http({
            method: "GET",
            url: "/dc/main_filter_ng",
            params: filterSentData
        })
    }
    return {
        request: function () {
            return doRequest()
        },
        setFilterSentData: function (newFilterSentData) {
            filterSentData = newFilterSentData
        }
    }
}])

services.factory("inspectorService", ["$http", function ($http) {
    var doRequest = function (id) {
        return $http({
            method: "GET",
            url: "/dc/inspector",
            params: {id: id}
        });
    };

   var getImg = function(id) {
        baseUrl = '/dc/conserv';
        return $http.get(baseUrl, {params: {id: id}});
   };
    return {
        request: function (id) {
          return doRequest(id);
        },
        get: function(id) {
          return getImg(id);
        }
    }
}])

services.factory("targetService", ["$http", function ($http) {
    var doRequest = function (id, gene) {
        if (!gene) {
            gene = ""
        }
        return $http({
            method: "GET",
            url: "/dc/putative_target_ng",
            params: {id: id, gene: gene}
        })

    }
    return {
        request: function (id, gene) {
            return doRequest(id, gene)
        }
    }
}])

services.factory('motifService', ["$http", function($http) {
    var doRequest = function(id, gene) {
        if (!gene) {
            gene = ""
        }
        return $http({
            method: "POST",
            url: "/dc/motif_ng",
            params: {id: id, gene:gene}
        })
    }
    return {
        request: function (id, gene) {
            return doRequest(id, gene)
        }
    }
}])

services.factory("similarService", ["$http", function ($http) {
    var doRequest = function (id) {
        return $http({
            method: "GET",
            url: "/dc/similarity",
            params: {id: id}
        })

    }
    return {
        request: function (id) {
            return doRequest(id)
        }
    }
}])

services.factory("loginService", ["$http", function ($http) {
       var doRequest = function () {
            return $http({
                method: "GET",
                url: "/dc/accounts/check"
            })
        }
        return {
            request: function () {
                return doRequest()
            }
        }

    }])
