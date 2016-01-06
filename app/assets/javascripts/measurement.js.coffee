$ ->
  loadHeatmap = (url, iteration) ->
    $.get url + '?iteration=' + iteration, (data) ->
      setHeatmapData(data)
      if iteration > 0
        setTimeout(
          () ->
            loadHeatmap(url, iteration - 1)
          500
        )
      else
        showSensors()

  setHeatmapData = (data) ->
    wrapper = new Object()
    result = []
    $.each data, (i, r) ->
      result.push({ long: r.sensor.long, lat: r.sensor.lat, value: r.value })
    wrapper.data = result
    wrapper.max = 500
    window.heatmapLayer.setData(wrapper)

  initHeatmap = ->
    unless window.heatmapLayer
      window.heatmapLayer = new HeatmapOverlay(heatmapConfig)

  showSensors = ->
    window.smogMap.removeLayer(window.heatmapLayer)
    window.markerLayer.eachLayer (sensorMarker) ->
      window.smogMap.addLayer(sensorMarker)

  showHeatmap = ->
    initHeatmap()
    window.markerLayer.eachLayer (sensorMarker) ->
      window.smogMap.removeLayer(sensorMarker)
    window.smogMap.addLayer(window.heatmapLayer)


  $('.measurement-button-24h').on 'click', (measurement) ->
    iteration = 10
    window.markerLayer.eachLayer (sensorMarker) ->
      window.smogMap.removeLayer(sensorMarker)
    showHeatmap()

    window.toggleSidebar() if window.isDeviceClass('xs')
    loadHeatmap(measurementUrl(measurement), iteration)

  $('.measurement-button').on 'click', (measurement) ->
    window.toggleSidebar() if window.isDeviceClass('xs')
    $.get measurementUrl(measurement), (data) ->
      showHeatmap()
      setHeatmapData(data)
      setTimeout(
        () -> showSensors()
        5000)

  measurementUrl = (measurement) ->
    'measurements/' + $(measurement.currentTarget).data('id')
