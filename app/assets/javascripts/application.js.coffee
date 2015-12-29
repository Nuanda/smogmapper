#= require jquery
#= require jquery.turbolinks
#= require jquery_ujs
#= require turbolinks
#= require i18n
#= require i18n/translations
#= require bootstrap-sprockets
#= require leaflet
#= require esri-leaflet
#= require js-routes
#= require leaflet-heatmap
#= require heatmap
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

window.toggleSidebar = (refreshMap = true) ->
  $('div#main').toggleClass('sidebar-show').promise().done =>
    if refreshMap
      setTimeout(
        ->
          window.smogMap.invalidateSize()
      , 250)
