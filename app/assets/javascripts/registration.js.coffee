$ ->
  $('#registration-button').on 'click', () ->
    if $('#new_location').length == 0
      $.get I18n.locale + '/locations/new', (data) ->
        $('#registration').html data

  $('#sidebar-left').on('ajax:success', '#new_location', (e, data, status, xhr) ->
    $('#registration').html xhr.responseText
  ).on('ajax:error', '#new_location', (e, xhr, status, error) ->
    $('#new_location').prepend "<div class='alert alert-danger'>Server error.</div>"
  )

  $('#sidebar-left').on 'click', '#sensor-show-button', ->
    $button = $(this)
    if window.isDeviceClass('xs')
      window.toggleSidebar(
        ->
          window.smogMap.invalidateSize()
        ,
        500
      )
    window.markerLayer.eachLayer (marker) ->
      if marker.dbId == $button.data('id')
        newLatLng = new L.LatLng($button.data('latitude'), $button.data('longitude'))
        marker.setLatLng(newLatLng)
    window.smogMap.setView([$button.data('latitude'), $button.data('longitude')], 14)
