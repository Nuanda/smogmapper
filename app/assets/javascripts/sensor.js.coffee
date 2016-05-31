# Aleja Krasińskiego: 6, channels 46 [pm10], 202 [pm2_5]
# Nowa Huta 7, channel 57 [pm10], 211 [pm2_5]
# Kurdwanów 16, channel 148 [pm10], 242 [pm2_5]
# Ulica Dietla 149, channel 1723 [pm10]
# Osiedle Piastów 152, channel 1747 [pm10]
# Ulica Złoty Róg 153, channel 1752 [pm10]

referenceNames = [
  'Aleja Krasińskiego'
  'Aleja Krasińskiego'
  'Nowa Huta'
  'Nowa Huta'
  'Kurdwanów'
  'Kurdwanów'
  'Ulica Dietla'
  'Osiedle Piastów'
  'Ulica Złoty Róg'
]

channels =
  'Aleja Krasińskiego': [46, 202]
  'Nowa Huta': [57, 211]
  'Kurdwanów': [148, 242]
  'Ulica Dietla': [1723]
  'Osiedle Piastów': [1747]
  'Ulica Złoty Róg': [1752]
  'all': [46, 202, 57, 211, 148, 242, 1723, 1747, 1752]

referenceLocations =
  'Aleja Krasińskiego':
    longitude: 19.926189
    latitude: 50.057678
  'Nowa Huta':
    longitude: 20.053492
    latitude: 50.069308
  'Kurdwanów':
    longitude: 19.949189
    latitude: 50.010575
  'Ulica Dietla':
    longitude: 19.946008
    latitude: 50.057447
  'Osiedle Piastów':
    longitude: 20.018317
    latitude: 50.099361
  'Ulica Złoty Róg':
    longitude: 19.895358
    latitude: 50.081197

window.loadReferenceData = (referenceName, latitude = null, longitude = null) ->
  today = new Date()

  queryJson = JSON.stringify
    measType: 'Auto'
    viewType: "Station"
    dateRange: "Day"
    date: today.getDate() + '.' + (today.getMonth() + 1) + '.' + today.getFullYear()
    channels: channels[referenceName]

  nearestReferenceName = 'none'
  if referenceName == 'all' && latitude && longitude
    shortestDistance = Number.POSITIVE_INFINITY
    sensorLatLng = L.latLng(latitude, longitude)
    for name, referenceLocation of referenceLocations
      referenceLatLng = L.latLng(referenceLocation['latitude'], referenceLocation['longitude'])
      referenceDistance = sensorLatLng.distanceTo(referenceLatLng)
      if referenceDistance < shortestDistance
        shortestDistance = referenceDistance
        nearestReferenceName = name

  $.post('http://smogmapper.info/reference',
    query: queryJson
    ,
    (data) ->
      pmChart = $('#reading-chart-container').highcharts()
      unless $('#reading-chart-container').data('reference')
        for series, i in data['data']['series']
          lastIndex = series['data'].length - 1
          if lastIndex > 0
            mName = series['paramCode'].toLowerCase().replace('.','_')
            if $('.' + mName).length > 0
              $('.' + mName + ' .reading-placeholder').text series['data'][lastIndex][1]
              time = new Date(parseInt(series['data'][lastIndex][0] * 1000, 10))
              minutes = ("0" + time.getMinutes()).slice(-2)
              seconds = ("0" + time.getSeconds()).slice(-2)
              $('.' + mName + ' .time-placeholder').text time.getHours() + ':' + minutes + ':' + seconds
          series['data'] = series['data'].map (dataPoint) -> [parseInt(dataPoint[0], 10), parseFloat(dataPoint[1])]
          if referenceName == 'all'
            series['name'] = referenceNames[i] + ' (' + series['paramCode'] + ')'
          else
            series['name'] = referenceName + ' (' + series['paramCode'] + ')'
          series['tooltip'] = {
            valueSuffix: 'μg/m³'
          }
          for axis, i in pmChart.yAxis
            series['yAxis'] = i if !axis['opposite']
          if nearestReferenceName != 'none' && series['name'].indexOf(nearestReferenceName) == -1
            series['visible'] = false
          pmChart.addSeries series
          $('#reading-chart-container').data('reference', true)
  ).fail ->
    $('#show-reference-button').attr("disabled", true)
    $('#no-reference-error').removeClass('hidden')


$ ->
  $('#sensor-modal-wrapper').on 'click', '#show-reference-button', (e) ->
    e.stopPropagation()
    e.preventDefault()
    window.loadReferenceData 'all', $(this).data('latitude'), $(this).data('longitude')

  $('#sensor-modal-wrapper').on 'click', '#rescale-button', (e) ->
    pmChart = $('#reading-chart-container').highcharts()
    series = pmChart.series.filter (s) -> s.options.dbName == $('#rescale-measurement').val()
    if series.length > 0
      rescaler = new Function('y', 'return ' + $('#rescale-function').val())
      t0 = Date.now()
      newData = ([d.x, rescaler(d.y)] for d in series[0].data)
      series[0].setData newData
      console.log Date.now() - t0

  $('#sensor-modal-wrapper').on 'change', '#rescale-measurement', (e) ->
    if $(e.target).val() == 'pm2_5'
      $('#rescale-function').val('y*1.4')
    else if $(e.target).val() == 'pm10'
      $('#rescale-function').val('y*0.8+30')
