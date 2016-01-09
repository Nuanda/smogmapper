class @Heatmap
  constructor: (smogMap) ->
    @smogMap = smogMap

  bind: (heatmap24h, heatmapCurrent) ->
    $(heatmap24h).on 'click', (measurement) =>
      @beforeClick()
      @show24hHeatmap($(measurement.currentTarget))

    $(heatmapCurrent).on 'click', (measurement) =>
      @beforeClick()
      @showCurrentHeatmap($(measurement.currentTarget))

  beforeClick: ->
    if @nextCallback
      clearTimeout(@nextCallback)
      @smogMap.showSensors()
    window.toggleSidebar() if window.isDeviceClass('xs')

  show24hHeatmap: (btn) ->
    $('.btn-measurement').removeClass('active')
    @smogMap.hideSensors()
    @smogMap.setHeatmapData([])
    @smogMap.showHeatmap()
    @loadHeatmap(@measurementUrl(btn), 10)

  showCurrentHeatmap: (btn) ->
    if btn.hasClass('active')
      $('.btn-measurement').removeClass('active')
      @smogMap.hideHeatmap()
    else
      btn.addClass('active')
      $.get @measurementUrl(btn), (data) =>
        @smogMap.showHeatmap()
        @smogMap.setHeatmapData(data)

  loadHeatmap: (url, iteration) ->
    $.get url + '?iteration=' + iteration, (data) =>
      @smogMap.setHeatmapData(data)
      if iteration > 0
        @nextCallback = setTimeout(
          () =>
            @loadHeatmap(url, iteration - 1)
          500
        )
      else
        @smogMap.hideHeatmap()
        @smogMap.showSensors()

  measurementUrl: (btn) ->
    'measurements/' + btn.data('id')
