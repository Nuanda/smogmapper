$ ->
  $('#registration-button').on 'click', () ->
    if $('#registration-form').length == 0
      $.get I18n.locale + '/locations/new', (data) ->
        $('#registration').html data

  $('#sidebar-left').on('ajax:success', '#new_location', (e, data, status, xhr) ->
    $('#registration').html xhr.responseText
  ).on('ajax:error', '#new_location', (e, xhr, status, error) ->
    $('#new_location').append "<p>TEMP ERROR</p>"
  )
