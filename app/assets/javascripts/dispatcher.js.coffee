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
      new SmogMap

  switchTabs: (targetTab) ->
    console.log "INIT [Dispatcher]: switching left section to #{targetTab}"
    $("#left-section a[href=#{targetTab}]").tab 'show'
