'use strict'

###*
 # @ngdoc function
 # @name dcApp.controller:AboutCtrl
 # @description
 # # AboutCtrl
 # Controller of the dcApp
###
angular.module('dcApp')
  .controller 'AboutCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
