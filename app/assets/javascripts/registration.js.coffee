$ ->
  $('#registration-button').on 'click', () ->
    if $('#registration-form').length == 0
      $.get 'locations/new', (data) ->
        $('#registration').html data
