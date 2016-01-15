module LocationHelper
  def locations_to_plotlines(locations)
    locations.map do |location|
      {
        color: 'red',
        width: 1,
        value: location.registration_time.to_i,
        label: {
          text: 'Location change'
        },
        zIndex: 5
      }
    end.to_json
  end
end
