
dcApp = angular.module("dcApp", [
  "dcApp.services"
  "blockUI"
  "angucomplete"
  "ngAnimate"
  "ngSanitize"
  "ngToast"
  "ngRoute"
  "ui.bootstrap"
  "ngSanitize",
  "com.2fdevs.videogular",
  "com.2fdevs.videogular.plugins.controls",
  "com.2fdevs.videogular.plugins.overlayplay",
  "com.2fdevs.videogular.plugins.poster",
  "com.2fdevs.videogular.plugins.buffering"  
])

.config (blockUIConfig) ->
  blockUIConfig.autoBlock = false
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
    .when('/tutorial', {
        templateUrl: 'views/tutorial.html'
    })
    .when('/test', {
      templateUrl: 'views/test.html'
    })


.constant("root", "http://cistrome.org")


