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

    @initSensors()

    $('#zoom-out-button').on 'click', =>
      # Zoom the map to proper bounds
      southWest = L.latLng config.MAX_BOUNDS_SOUTH, config.MAX_BOUNDS_WEST
      northEast = L.latLng config.MAX_BOUNDS_NORTH, config.MAX_BOUNDS_EAST
      bounds = L.latLngBounds southWest, northEast
      window.smogMap.fitBounds bounds

  initSensors: ->
    window.markerLayer = L.layerGroup()

    bigIcon = L.icon
      iconUrl: 'assets/images/marker-icon-2x.png'
      iconAnchor:   [20, 80] # point of the icon which will correspond to marker's location

    sensorIcon = L.icon
      iconUrl: 'assets/images/sensor-marker.png',
      iconSize:     [25, 25] # size of the icon
      iconAnchor:   [13, 13] # point of the icon which will correspond to marker's location

    lastSensorId = @config.get("sensor.id", Number)

    $.get 'sensors.json', (data) =>
      $(data).each (i, sensor) =>
        sensorMarker = if sensor.id == 1000
          L.marker([sensor['locations'][0]['latitude'], sensor['locations'][0]['longitude']], { icon: bigIcon })
        else
          L.marker([sensor['locations'][0]['latitude'], sensor['locations'][0]['longitude']], { icon: sensorIcon })
        window.markerLayer.addLayer(sensorMarker)
        sensorMarker.addTo(window.smogMap).
          on 'click', (sensor) =>
            if window.isDeviceClass('xs')
              window.toggleSidebar () =>
                @loadSensor(sensor)
            else
              @loadSensor(sensor)

        sensorMarker.dbId = sensor.id

        if lastSensorId == sensor.id
          window.smogMap.setView([sensor['locations'][0]['latitude'], sensor['locations'][0]['longitude']], 14)

  loadSensor: (sensor) ->
    $.get 'sensors/' + sensor.target.dbId, (data) ->
      $('#sensors-tab').html data
      $('#left-section a[href="#sensors-tab"]').tab 'show'

    @config.set("sensor.id", sensor.target.dbId)

  showSensors: ->
    window.markerLayer.eachLayer (sensorMarker) ->
      window.smogMap.addLayer(sensorMarker)

  hideSensors: ->
    window.markerLayer.eachLayer (sensorMarker) ->
      window.smogMap.removeLayer(sensorMarker)

  showHeatmap: ->
    @initHeatmap()
    window.smogMap.addLayer(window.heatmapLayer)

  initHeatmap: ->
    unless window.heatmapLayer
      window.heatmapLayer = new HeatmapOverlay(heatmapConfig)

  hideHeatmap: ->
    window.smogMap.removeLayer(window.heatmapLayer)

  setHeatmapData: (data) ->
    @initHeatmap()
    wrapper = new Object()
    result = []
    $.each data, (i, r) ->
      result.push({ long: r.sensor.long, lat: r.sensor.lat, value: r.value })
    wrapper.data = result
    wrapper.max = 500
    window.heatmapLayer.setData(wrapper)
