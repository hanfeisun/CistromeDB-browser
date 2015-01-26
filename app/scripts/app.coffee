
dcApp = angular.module("dcApp", [
  "dcApp.services"
  "blockUI"
  "angucomplete"
  "ngToast"
])

.config (blockUIConfig) ->
  blockUIConfig.autoBlock = false
  return

.config (
  ['ngToastProvider'
   (ngToast) ->
     ngToast.configure
       verticalPosition: 'bottom',
       horizontalPosition: 'right'
     return
  ]
)

.constant("root", "http://cistrome.org")


