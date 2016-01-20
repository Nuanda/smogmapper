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

      get_measurement
      result = json_response

      expect(result.size).to eq 1
      expect(result[0]['value']).to eq new_reading.value
    end

    it 'caches readings until new reading appear' do
      create_reading
      # cache results
      get_measurement

      # 2 queries are made: to check latest reading time,
      # and to check number of readings
      expect { get_measurement }.to make_database_queries(count: 2)
    end

    it 'returns latest results' do
      create_reading
      l = create(:location, sensor: sensor)
      # cache results
      get_measurement

      new_reading = create_reading
      get_measurement

      expect(response.body).to include new_reading.value.to_s
      expect(response.body).to include l.latitude.to_s
      expect(response.body).to include l.longitude.to_s
    end

    it 'does not return values older then interval' do
      create_reading(Time.now - 20.minutes)
      create(:location, sensor: sensor, registration_time: 1.hour.ago)

      get_measurement

      expect(json_response).to eq []
    end

    it 'does not return cached values older then interval' do
      now = Time.now
      create_reading(now - 5.minutes)

      sensor2 = create(:sensor, measurements: [measurement])
      last = create(:reading, measurement: measurement,
                    sensor: sensor2, time: now - 3.minutes)

      create(:location, sensor: sensor, registration_time: 1.hour.ago)
      create(:location, sensor: sensor2, registration_time: 1.hour.ago)

      # create cache
      get_measurement
      # time travel + 11 minutes
      allow(Time).to receive(:now).and_return(now + 11.minutes)
      get_measurement
      result = json_response

      expect(result.size).to eq 1
      expect(result[0]['value']).to eq last.value
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

      get_measurement 0
      result = json_response

      expect(result.size).to eq 1
      expect(result[0]['value']).to eq current.value
    end

    it 'does\'t return data older then interval' do
      before_interval = Time.new(2015, 1, 1, 11, 44)
      create_reading(before_interval)
      create(:location, sensor: sensor, registration_time: before_interval)

      get_measurement 0

      expect(json_response).to eq []
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

  def json_response
    JSON.parse(response.body)
  end

  def create_reading(time = Time.now)
    create(:reading, measurement: measurement, sensor: sensor, time: time)
  end

  def get_measurement(iteration = nil)
    if iteration
      get measurement_path(id: measurement.id), { iteration: iteration }, json_header
    else
      get measurement_path(id: measurement.id), nil, json_header
    end
  end
end
