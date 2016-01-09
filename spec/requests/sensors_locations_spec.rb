require 'rails_helper'

RSpec.describe "Sensors list" do
  let(:json_header) { { "ACCEPT" => "application/json" } }

  it 'returns only last sensor location' do
    sensor = create(:sensor)
    create(:location, sensor: sensor)
    latest_location = create(:location, sensor: sensor)

    get sensors_path, nil, json_header

    expect(json_response[0]).to include('id' => sensor.id,
                                 'latitude' => latest_location.latitude,
                                 'longitude' => latest_location.longitude)
  end

  it 'returns only sensors with location' do
    create(:sensor)
    sensor = create(:sensor)
    create(:location, sensor: sensor)

    get sensors_path, nil, json_header

    expect(json_response.size).to eq 1
    expect(json_response[0]['id']).to eq sensor.id
  end

  def json_response
    JSON.parse(response.body)
  end
end
