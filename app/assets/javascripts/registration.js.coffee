$ ->
  $('#registration-button').on 'click', () ->
    if $('#registration-form').length == 0
      $.get I18n.locale + '/locations/new', (data) ->
        $('#registration').html data
