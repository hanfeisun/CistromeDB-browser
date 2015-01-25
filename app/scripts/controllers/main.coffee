'use strict'

###*
 # @ngdoc function
 # @name dcApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the dcApp
###
angular.module('dcApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
