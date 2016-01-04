class @SmogMap
  constructor: (config) ->
    @config = config

    L.Icon.Default.imagePath = 'assets/images'

    $('#smog-map').css('min-height', window.innerHeight - 50)

    # Create a map in the "map" div, set the view to Kraków and zoom level to 13
    window.smogMap = L.map('smog-map', { zoomControl: false })
                .setView [50.06, 19.95], 13
    new L.Control.Zoom(
      zoomInTitle: I18n.t('map.zoom_in')
      zoomOutTitle: I18n.t('map.zoom_out')
    ).addTo window.smogMap

    L.tileLayer(config.CDB_TILE_URL,{
      attribution: config.OSM_ATTRIBUTION + ', ' + config.CDB_ATTRIBUTION
    }).addTo window.smogMap

    bigIcon = L.icon
      iconUrl: 'assets/images/marker-icon-2x.png'
      iconAnchor:   [20, 80] # point of the icon which will correspond to marker's location

    sensorIcon = L.icon
      iconUrl: 'assets/images/sensor-marker.png',
      iconSize:     [25, 25] # size of the icon
      iconAnchor:   [13, 13] # point of the icon which will correspond to marker's location

    window.markerLayer = L.layerGroup()
    $.get 'sensors.json', (data) =>
      $(data).each (i, sensor) =>
        sensorMarker = if sensor.id == 1000
          L.marker([sensor['lat'], sensor['long']], { icon: bigIcon })
        else
          L.marker([sensor['lat'], sensor['long']], { icon: sensorIcon })
        window.markerLayer.addLayer(sensorMarker)
        sensorMarker.addTo(window.smogMap).
          on 'click', (sensor) =>
            if window.isDeviceClass('xs')
              window.toggleSidebar () =>
                SmogMap.loadSensor(sensor)
            else
              SmogMap.loadSensor(sensor)
        sensorMarker.dbId = sensor.id

    $('#zoom-out-button').on 'click', =>
      # Zoom the map to proper bounds
      southWest = L.latLng config.MAX_BOUNDS_SOUTH, config.MAX_BOUNDS_WEST
      northEast = L.latLng config.MAX_BOUNDS_NORTH, config.MAX_BOUNDS_EAST
      bounds = L.latLngBounds southWest, northEast
      window.smogMap.fitBounds bounds

  @loadSensor: (sensor) ->
    $.get 'sensors/' + sensor.target.dbId, (data) ->
      $('#sensors-tab').html data
      $('#left-section a[href="#sensors-tab"]').tab 'show'
