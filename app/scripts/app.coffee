
dcApp = angular.module("dcApp", [
  "dcApp.services"
  "blockUI"
  "angucomplete-alt"
  "ngAnimate"
  "ngSanitize"
  "LocalStorageModule"
  "ngToast"
  "ngRoute"
  "ui.bootstrap"
  "com.2fdevs.videogular",
  "com.2fdevs.videogular.plugins.controls",
  "com.2fdevs.videogular.plugins.overlayplay",
  "com.2fdevs.videogular.plugins.poster",
  "com.2fdevs.videogular.plugins.buffering"
])

.config (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix('ls');

.config (blockUIConfig) ->
  blockUIConfig.message = 'Please Wait...'
  return

.config ['ngToastProvider'
         (ngToast) ->
           ngToast.configure(
             #verticalPosition: 'bottom'
             #horizontalPosition: 'center'
           )
           return
]

.config ($routeProvider, $locationProvider) ->
  $routeProvider
    .when('/', {
        templateUrl: 'views/main.html'
      })
    .when('/about', {
        templateUrl: 'views/about.html'
    })
    .when('/stat', {
        templateUrl: 'views/stat.html'
    })
    .when('/faq', {
        templateUrl: 'views/faq.html'
    })
    .when('/tutorial', {
        templateUrl: 'views/tutorial.html'
    })
    .when('/test', {
      templateUrl: 'views/test.html'
    })
.constant("root", "http://dc2.cistrome.org/api")
.constant("root2", "http://dc2.cistrome.org/")
