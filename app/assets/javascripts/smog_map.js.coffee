class @SmogMap
  constructor: ->
    L.Icon.Default.imagePath = 'assets/images'

    $('#smog-map').css('min-height', window.innerHeight - 50)

    window.heatmapLayer = new HeatmapOverlay(cfg)

    # Create a map in the "map" div, set the view to Kraków and zoom level to 13
    window.smogMap = L.map('smog-map', { zoomControl: false, layers: [window.heatmapLayer] })
                .setView [50.06, 19.95], 13
    new L.Control.Zoom(
      zoomInTitle: I18n.t('map.zoom_in')
      zoomOutTitle: I18n.t('map.zoom_out')
    ).addTo window.smogMap

    L.tileLayer(Config.CDB_TILE_URL,{
      attribution: Config.OSM_ATTRIBUTION + ', ' + Config.CDB_ATTRIBUTION
    }).addTo window.smogMap

#    window.heatmapLayer.setData(retrieveData())

    $.get 'sensors.json', (data) =>
      $(data).each (i, sensor) =>
        sensorMarker = L.marker([sensor['long'], sensor['lat']]).
          addTo(window.smogMap).
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
      window.smogMap.fitBounds bounds
