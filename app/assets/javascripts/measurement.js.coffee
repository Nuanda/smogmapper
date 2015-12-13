$ ->
  $('.measurement-button').on 'click', (measurement) ->
    $.get 'measurements/' + $(measurement.currentTarget).data('id'), (data) ->
#      console.log data
      $.each data, (i, r) ->
        console.log r
      window.heatmapLayer.setData(retrieveData())

#              $('#sensors-tab').html data
#              $('#left-section a[href="#sensors-tab"]').tab 'show'
#        sensorMarker.dbId = sensor.id
#
#    $('#zoom-out-button').on 'click', =>
#      # Zoom the map to proper bounds
#      southWest = L.latLng Config.MAX_BOUNDS_SOUTH, Config.MAX_BOUNDS_WEST
#      northEast = L.latLng Config.MAX_BOUNDS_NORTH, Config.MAX_BOUNDS_EAST
#      bounds = L.latLngBounds southWest, northEast
#      @smogMap.fitBounds bounds
