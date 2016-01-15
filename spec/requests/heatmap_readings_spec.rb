require 'rails_helper'

RSpec.describe "Heatmap" do
  let(:measurement) { create(:measurement) }
  let(:sensor) { create(:sensor, measurements: [measurement]) }
  let(:json_header) { { "ACCEPT" => "application/json" } }

  context 'time now' do
    it 'showns heatmap' do
      # old reading
      create_reading(Time.now - 20.minutes)
      new_reading = create_reading(Time.now - 1.second)
      create(:location, sensor: sensor)

      get measurement_path(id: measurement.id), nil, json_header
      result = json_response

      expect(result.size).to eq 1
      expect(result[0]['value']).to eq new_reading.value
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
      l = create(:location, sensor: sensor)
      # cache results
      get measurement_path(id: measurement.id), nil, json_header

      new_reading = create_reading
      get measurement_path(id: measurement.id), nil, json_header

      expect(response.body).to include new_reading.value.to_s
      expect(response.body).to include l.latitude.to_s
      expect(response.body).to include l.longitude.to_s
    end

    it 'does not return values older then interval' do
      create_reading(Time.now - 20.minutes)
      create(:location, sensor: sensor, registration_time: 1.hour.ago)

      get measurement_path(id: measurement.id), nil, json_header

      expect(json_response).to eq []
    end

    it 'does not return cached values older then interval' do
      now = Time.now
      create_reading(now - 5.minutes)
      create(:location, sensor: sensor, registration_time: 1.hour.ago)

      # create cache
      get measurement_path(id: measurement.id), nil, json_header
      # time travel + 11 minutes
      allow(Time).to receive(:now).and_return(now + 11.minutes)
      get measurement_path(id: measurement.id), nil, json_header

      expect(json_response).to eq []
    end
  end

  context 'iteration' do
    before do
      # interval from 11:45 to 12:00
      allow(Time).to receive(:now).
        and_return(Time.new(2015, 1, 1, 12, 5))
    end

    it 'returns results from iteration interval' do
      create_reading(Time.new(2015, 1, 1, 11, 44)) # before
      current = create_reading(Time.new(2015, 1, 1, 11, 50))
      create_reading(Time.new(2015, 1, 1, 12, 1)) # after
      create(:location, sensor: sensor)

      get measurement_path(id: measurement.id), { iteration: 0 }, json_header
      result = json_response

      expect(result.size).to eq 1
      expect(result[0]['value']).to eq current.value
    end

    it 'does\'t return data older then interval' do
      before_interval = Time.new(2015, 1, 1, 11, 44)
      create_reading(before_interval)
      create(:location, sensor: sensor, registration_time: before_interval)

      get measurement_path(id: measurement.id), { iteration: 0 }, json_header

      expect(json_response).to eq []
    end

    it 'uses cache for iteration data' do
      create_reading(Time.new(2015, 1, 1, 11, 50))
      #make sure cache is created
      get measurement_path(id: measurement.id), { iteration: 0 }, json_header

      expect do
        get measurement_path(id: measurement.id), { iteration: 0 }, json_header
      end.to_not make_database_queries
    end
  end

  def json_response
    JSON.parse(response.body)
  end

  def create_reading(time = Time.now)
    create(:reading, measurement: measurement, sensor: sensor, time: time)
  end
end
