class @SmogMap
  constructor: (config) ->
    @config = config

    L.Icon.Default.imagePath = 'assets/images'

    $('#smog-map').css('min-height', window.innerHeight - 50)

    # Create a map in the "map" div, set the view to Kraków and zoom level to 13
    window.smogMap = L.map('smog-map', { zoomControl: false })

    new L.Control.Zoom(
      zoomInTitle: I18n.t('map.zoom_in')
      zoomOutTitle: I18n.t('map.zoom_out')
    ).addTo window.smogMap

    L.tileLayer(config.CDB_TILE_URL,{
      attribution: config.OSM_ATTRIBUTION + ', ' + config.CDB_ATTRIBUTION
    }).addTo window.smogMap

    @initSensors()

    window.smogMap.setView([50.06, 19.95], 13) unless window.smogMap.getZoom()

    $('#zoom-out-button').on 'click', =>
      # Zoom the map to proper bounds
      southWest = L.latLng config.MAX_BOUNDS_SOUTH, config.MAX_BOUNDS_WEST
      northEast = L.latLng config.MAX_BOUNDS_NORTH, config.MAX_BOUNDS_EAST
      bounds = L.latLngBounds southWest, northEast
      window.smogMap.fitBounds bounds

  initSensors: ->
    window.markerLayer = L.layerGroup()

    @bigIcon = L.icon
      iconUrl: 'assets/images/marker-icon-2x.png'
      iconAnchor:   [20, 80] # point of the icon which will correspond to marker's location

    @sensorIcon = L.icon
      iconUrl: 'assets/images/sensor-marker.png',
      iconSize:     [25, 25] # size of the icon
      iconAnchor:   [13, 13] # point of the icon which will correspond to marker's location

    lastSensorId = @getLastSensorId()

    $.get 'sensors.json', (data) =>
      $(data).each (i, sensor) =>
        @addSensorMarker sensor.id, sensor['latitude'], sensor['longitude']
        if lastSensorId == sensor.id
          window.smogMap.setView([sensor['latitude'], sensor['longitude']], 14)

  addSensorMarker: (sensorId, latitude, longitude) ->
    icon = if sensorId == 1000 then @bigIcon else @sensorIcon
    sensorMarker = L.marker([latitude, longitude], { icon: icon, zIndexOffset: 10000 })
    window.markerLayer.addLayer(sensorMarker)
    sensorMarker.addTo(window.smogMap).
      on 'click', (sensor) =>
        @loadSensor(sensor.target.dbId)
        @setLastSensorId(sensor.target.dbId)

    sensorMarker.dbId = sensorId

  loadSensor: (sensorId) ->
    $.get I18n.locale + '/sensors/' + sensorId, (data) ->
      $('#sensor-modal-wrapper').html data

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
      result.push({ longitude: r.longitude, latitude: r.latitude, value: r.value })
    wrapper.data = result
    wrapper.max = 500
    window.heatmapLayer.setData(wrapper)

  setLastSensorId: (sensorId) ->
    @config.set("sensor.id", sensorId)

  getLastSensorId: ->
    @config.get("sensor.id", Number)

