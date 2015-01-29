
dcApp = angular.module("dcApp", [
  "dcApp.services"
  "blockUI"
  "angucomplete"
  "ngAnimate"
  "ngSanitize"
  "ngToast"
  "ui.bootstrap"
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


.constant("root", "http://cistrome.org")


