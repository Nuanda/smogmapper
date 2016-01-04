#= require jquery
#= require jquery_ujs
#= require i18n
#= require i18n/translations
#= require bootstrap-sprockets
#= require leaflet
#= require esri-leaflet
#= require js-routes
#= require leaflet-heatmap
#= require heatmap
#= require highcharts
#= require_tree .

$ ->
  # Flash
  if (flash = $(".flash-container")).length > 0
    flash.click -> $(@).fadeOut()
    flash.show()
    setTimeout (-> flash.fadeOut()), 5000

  # Tooltips
  $('body').tooltip
    delay:
      show: 300
      hide: 0
    container: 'body'
    selector: '[title]'

  $('body').on 'click', '#show-sidebar', (e) ->
    e.preventDefault()
    window.toggleSidebar()

  unless window.isDeviceClass('xs')
    $('div#main').toggleClass('sidebar-show')

window.toggleSidebar = (completeCallback = null) ->
  $('div#main').toggleClass('sidebar-show').promise().done =>
    if completeCallback
      setTimeout(
        ->
          completeCallback()
      , 250)

window.isDeviceClass = (alias) ->
  $('.device-' + alias).is(':visible')
