$ ->
  new Dispatcher


class Dispatcher
  constructor: ->
    @initScripts()

  initScripts: ->
    dispatch = $('body').attr('data-dispatch')

    return false unless dispatch

    console.log "INIT [Dispatcher]: #{dispatch} dispatched"

    @initSmogMap()

#    switch dispatch
#      when 'home:index'
#        Something.initialize()
#      when 'sensors:show'
#        SomethingElse.initialize()

  initSmogMap: ->
    console.log 'INIT [Dispatcher]: initializing Smog Map component'
    if $('#smog-map').length > 0
      window.smogMapManager = new SmogMap(Config)
      window.smogMap = window.smogMapManager.smogMap
      new Heatmap(window.smogMapManager).
        bind('.measurement-button-24h', '.measurement-button')

  switchTabs: (targetTab) ->
    console.log "INIT [Dispatcher]: switching left section to #{targetTab}"
    $("#left-section a[href=#{targetTab}]").tab 'show'
