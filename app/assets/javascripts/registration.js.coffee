$ ->
  $('#registration-button').on 'click', () ->
    if $('#registration-form').length == 0
      $.get 'sensors/new', (data) ->
        $('#registration').html data
