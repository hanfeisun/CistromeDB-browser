'use strict'

###*
 # @ngdoc overview
 # @name dcApp
 # @description
 # # dcApp
 #
 # Main module of the application.
###
angular
  .module('dcApp', [
    'ngRoute'
  ])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/about',
        templateUrl: 'views/about.html'
        controller: 'AboutCtrl'
      .otherwise
        redirectTo: '/'

