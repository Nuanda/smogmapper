class @SmogMap
  constructor: (config) ->
    @config = config

    L.Icon.Default.imagePath = 'assets/images'

    $('#smog-map').css('min-height', window.innerHeight - 50)

    @smogMap = L.map('smog-map',
      {
        zoomControl: false
        contextmenu: true
        contextmenuWidth: 140
        contextmenuItems: [
          text: "<b>+</b> " + I18n.t('registration.add_sensor')
          callback: @addSensor
        ]
      }
    )

    new L.Control.Zoom(
      zoomInTitle: I18n.t('map.zoom_in')
      zoomOutTitle: I18n.t('map.zoom_out')
    ).addTo @smogMap

    L.tileLayer(config.CDB_TILE_URL,{
      attribution: config.OSM_ATTRIBUTION + ', ' + config.CDB_ATTRIBUTION
    }).addTo @smogMap

    @initSensors()

    $('#zoom-out-button').on 'click', =>
      # Zoom the map to proper bounds
      southWest = L.latLng config.MAX_BOUNDS_SOUTH, config.MAX_BOUNDS_WEST
      northEast = L.latLng config.MAX_BOUNDS_NORTH, config.MAX_BOUNDS_EAST
      bounds = L.latLngBounds southWest, northEast
      @smogMap.fitBounds bounds

  addSensor: (e) ->
    window.toggleSidebar() if window.isDeviceClass('xs')
    $('#left-section a[href="#registration-tab"]').tab('show')
    if $('#new_location').length == 0
      $.get I18n.locale + '/locations/new', (data) ->
        $('#registration').html data
        $('#location_latitude').val(e.latlng['lat'])
        $('#location_longitude').val(e.latlng['lng'])
    else
      $('#location_latitude').val(e.latlng['lat'])
      $('#location_longitude').val(e.latlng['lng'])

  initSensors: ->
    @markerLayer = L.layerGroup()

    @bigIcon = L.icon
      iconUrl: 'assets/images/marker-icon-2x.png'
      iconAnchor:   [20, 80] # point of the icon which will correspond to marker's location

    @sensorIcon = L.icon
      iconUrl: 'assets/images/sensor-marker.png',
      iconSize:     [25, 25] # size of the icon
      iconAnchor:   [13, 13] # point of the icon which will correspond to marker's location

    @referenceIcon = L.icon
      iconUrl: 'assets/images/reference-marker.png',
      iconSize:     [25, 25]
      iconAnchor:   [13, 13]

    lastSensorId = @getLastSensorId()

    $.get 'sensors.json', (data) =>
      lastSensorFound = false
      $(data).each (i, sensor) =>
        @addSensorMarker sensor.id, sensor['latitude'], sensor['longitude'], sensor['sensor_type'] == 'reference'
        if lastSensorId == sensor.id
          @smogMap.setView([sensor['latitude'], sensor['longitude']], 14)
          lastSensorFound = true
        if (i == $(data).length - 1) && !lastSensorFound
          # Set the view to Kraków and zoom level to 13 as a default behaviour
          @smogMap.setView([50.06, 19.95], 13)

  addSensorMarker: (sensorId, latitude, longitude, reference = false) ->
    icon = switch
      when reference then @referenceIcon
      when sensorId == 1000 then @bigIcon
      else @sensorIcon
    sensorMarker = L.marker([latitude, longitude], { icon: icon, zIndexOffset: 10000 })
    @markerLayer.addLayer(sensorMarker)
    sensorMarker.addTo(@smogMap).
      on 'click', (sensor) =>
        @loadSensor(sensor.target.dbId)
        @setLastSensorId(sensor.target.dbId)

    sensorMarker.dbId = sensorId

  loadSensor: (sensorId) ->
    $.get I18n.locale + '/sensors/' + sensorId, (data) ->
      $('#sensor-modal-wrapper').html data

  showSensors: ->
    @markerLayer.eachLayer (sensorMarker) ->
      @smogMap.addLayer(sensorMarker)

  hideSensors: ->
    @markerLayer.eachLayer (sensorMarker) ->
      @smogMap.removeLayer(sensorMarker)

  showHeatmap: ->
    @initHeatmap()
    @smogMap.addLayer(window.heatmapLayer)

  initHeatmap: ->
    unless window.heatmapLayer
      window.heatmapLayer = new HeatmapOverlay(heatmapConfig)

  hideHeatmap: ->
    @smogMap.removeLayer(window.heatmapLayer)

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

