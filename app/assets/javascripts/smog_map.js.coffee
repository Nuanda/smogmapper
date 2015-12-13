class @SmogMap
  constructor: ->
    $('#smog-map').css('min-height', window.innerHeight - 50)

    # Create a map in the "map" div, set the view to Kraków and zoom level to 13
    @smogMap = L.map('smog-map', { zoomControl: false })
                .setView [50.06, 19.95], 13
    new L.Control.Zoom(
      zoomInTitle: I18n.t('map.zoom_in')
      zoomOutTitle: I18n.t('map.zoom_out')
    ).addTo @smogMap

    L.tileLayer(Config.CDB_TILE_URL,{
      attribution: Config.OSM_ATTRIBUTION + ', ' + Config.CDB_ATTRIBUTION
    }).addTo @smogMap

    $.get 'sensors.json', (data) =>
      $(data).each (i, sensor) =>
        sensorMarker = L.marker([sensor['long'], sensor['lat']]).
          addTo(@smogMap).
          on 'click', (sensor) =>
            $.get 'sensors/' + sensor.target.dbId, (data) ->
              $('#sensors-tab').html data
              $('#left-section a[href="#sensors-tab"]').tab 'show'
        sensorMarker.dbId = sensor.id

    $('#zoom-out-button').on 'click', =>
      # Zoom the map to proper bounds
      southWest = L.latLng Config.MAX_BOUNDS_SOUTH, Config.MAX_BOUNDS_WEST
      northEast = L.latLng Config.MAX_BOUNDS_NORTH, Config.MAX_BOUNDS_EAST
      bounds = L.latLngBounds southWest, northEast
      @smogMap.fitBounds bounds
