#window.iterationBlock = -1

$ ->
  loadHeatmap = (url, iteration) ->
    $.get url + '?iteration=' + iteration, (data) ->
      wrapper = new Object()
      result = []
      $.each data, (i, r) ->
#        console.log r.value
        result.push({ long: r.sensor.long, lat: r.sensor.lat, value: r.value })
      wrapper.data = result
      console.log wrapper
      window.heatmapLayer.setData(wrapper)
      window.smogMap._onResize()
      if iteration > 0
        setTimeout(
          () ->
            console.log iteration - 1
            loadHeatmap(url, iteration - 1)
          1000
        )
#        loadHeatmap(url, iteration - 1)
#      console.log '*'
#      window.iterationBlock = iteration

#  waitForDataLoad = (iteration) ->
#    console.log '.'
#    if iteration != window.iterationBlock
#      setTimeout waitForDataLoad(iteration), 1000
#      return

  $('.measurement-button').on 'click', (measurement) ->
    url = 'measurements/' + $(measurement.currentTarget).data('id')
    iteration = 10
    loadHeatmap(url, iteration)

#    animation = setInterval(
#      () ->
#        console.log iteration
#        loadHeatmap(url, iteration)
#        iteration = iteration - 1
#        if (iteration == -1)
#          clearInterval(animation)
#        else
#          waitForDataLoad(iteration)
#      1000
#    )


#    $.get url + '?iteration=' + iteration, (data) ->
#      wrapper = new Object()
#      result = []
#      $.each data, (i, r) ->
#        result.push({ long: r.sensor.long, lat: r.sensor.lat, value: r.value })
#      wrapper.data = result
#      window.heatmapLayer.setData(wrapper)

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
