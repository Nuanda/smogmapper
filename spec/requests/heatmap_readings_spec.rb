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
      result = JSON.parse(response.body)

      expect(result.size).to eq 1
      expect(result[0]['value']).to eq new_reading.value
    end

    it 'caches readings until new reading appear' do
      create_reading
      # cache results
      get measurement_path(id: measurement.id), nil, json_header

      # 2 queries are made: to check latest reading time, and to check readings numbers
      expect { get_measurement }.to make_database_queries(count: 2)
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
      result = JSON.parse(response.body)

      expect(result.size).to eq 1
      expect(result[0]['value']).to eq current.value
    end

    it 'uses cache for iteration data' do
      create_reading(Time.new(2015, 1, 1, 11, 50))
      create(:location, sensor: sensor)
      #make sure cache is created
      get_measurement 0

      expect { get_measurement 0 }.to make_database_queries(count: 1)
    end

    it 'invalidates cache if new reading appears for given iteration' do
      create_reading(Time.new(2015, 1, 1, 11, 40))
      create(:location, sensor: sensor)
      # cache is created
      expect { get_measurement 1 }.to make_database_queries(count: 2)
      # cache is used
      expect { get_measurement 1 }.to make_database_queries(count: 1)
      create_reading(Time.new(2015, 1, 1, 11, 41))
      # cache is re-created
      expect { get_measurement 1 }.to make_database_queries(count: 2)
    end
  end

  def create_reading(time = Time.now)
    create(:reading, measurement: measurement, sensor: sensor, time: time)
  end

  def get_measurement(iteration = nil)
    get measurement_path(id: measurement.id), { iteration: iteration }, json_header
  end
end
