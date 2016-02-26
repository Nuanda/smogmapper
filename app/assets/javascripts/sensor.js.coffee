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

channels = {
  'Aleja Krasińskiego': [46, 202]
  'Nowa Huta': [57, 211]
  'Kurdwanów': [148, 242]
  'Ulica Dietla': [1723]
  'Osiedle Piastów': [1747]
  'Ulica Złoty Róg': [1752]
  'all': [46, 202, 57, 211, 148, 242, 1723, 1747, 1752]
}

window.loadReferenceData = (referenceName) ->
  today = new Date()

  queryJson = JSON.stringify
    measType: 'Auto'
    viewType: "Station"
    dateRange: "Day"
    date: today.getDate() + '.' + (today.getMonth() + 1) + '.' + today.getFullYear()
    channels: channels[referenceName]

  $.post('http://smogmapper.info/reference',
    query: queryJson
    ,
    (data) ->
      pmChart = $('#reading-chart-container').highcharts()
      unless $('#reading-chart-container').data('reference')
        for series, i in data['data']['series']
          series['data'] = series['data'].map (dataPoint) -> [parseInt(dataPoint[0], 10), parseFloat(dataPoint[1])]
          series['name'] = referenceNames[i] + ' (' + series['paramCode'] + ')'
          series['tooltip'] = {
            valueSuffix: 'μg/m³'
          }
          for axis, i in pmChart.yAxis
            series['yAxis'] = i if !axis['opposite']
          pmChart.addSeries series
          $('#reading-chart-container').data('reference', true)
  ).fail ->
    $('#show-reference-button').attr("disabled", true)
    $('#no-reference-error').removeClass('hidden')


$ ->
  $('#sensor-modal-wrapper').on 'click', '#show-reference-button', (e) ->
    e.stopPropagation()
    e.preventDefault()
    window.loadReferenceData 'all'

  $('#sensor-modal-wrapper').on 'click', '#rescale-button', (e) ->
    pmChart = $('#reading-chart-container').highcharts()
    series = pmChart.series.filter (s) -> s.options.dbName == $('#rescale-measurement').val()
    if series.length > 0
      rescaler = new Function('y', 'return ' + $('#rescale-function').val())
      t0 = Date.now()
      newData = ([d.x, rescaler(d.y)] for d in series[0].data)
      series[0].setData newData
      console.log Date.now() - t0
