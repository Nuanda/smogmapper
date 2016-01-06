require 'rails_helper'

RSpec.describe "Heatmap" do
  let(:measurement) { create(:measurement) }
  let(:sensor) { create(:sensor) }
  let(:json_header) { { "ACCEPT" => "application/json" } }

  context 'time now' do
    it 'showns heatmap' do
      # old reading
      create_reading(Time.now - 20.minutes)
      new_reading = create_reading


      get measurement_path(id: measurement.id), nil, json_header
      result = JSON.parse(response.body)

      expect(result.size).to eq 1
      expect(result[0]['id']).to eq new_reading.id
    end

    it 'caches readings until new reading appear' do
      create_reading
      # cache results
      get measurement_path(id: measurement.id), nil, json_header

      # one query is made to check latest reading
      expect { get measurement_path(id: measurement.id), nil, json_header }.
        to make_database_queries(count: 1)
    end

    it 'returns latest results' do
      create_reading
      # cache results
      get measurement_path(id: measurement.id), nil, json_header

      new_reading = create_reading
      get measurement_path(id: measurement.id), nil, json_header

      expect(response.body).to include new_reading.to_json(include: :sensor)
    end
  end

  def create_reading(time = Time.now)
    create(:reading, measurement: measurement, sensor: sensor, time: time)
  end
end
