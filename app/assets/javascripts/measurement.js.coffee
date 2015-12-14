$ ->
  loadHeatmap = (url, iteration) ->
    $.get url + '?iteration=' + iteration, (data) ->
      wrapper = new Object()
      result = []
      $.each data, (i, r) ->
        result.push({ long: r.sensor.long, lat: r.sensor.lat, value: r.value })
      wrapper.data = result
      wrapper.max = 500
      window.heatmapLayer.setData(wrapper)
      if iteration > 0
        setTimeout(
          () ->
            loadHeatmap(url, iteration - 1)
          500
        )

  $('.measurement-button').on 'click', (measurement) ->
    url = 'measurements/' + $(measurement.currentTarget).data('id')
    iteration = 10
    window.smogMap.eachLayer (layer) ->
      if layer._latlng
        window.smogMap.removeLayer(layer)
    loadHeatmap(url, iteration)
