require 'rails_helper'

RSpec.describe "Readings" do
  let(:measurement) { create(:measurement) }
  let(:other_measurement) { create(:measurement) }
  let(:sensor) { create(:sensor, measurements: [measurement]) }
  let(:now) { Time.now }
  let(:past) { Time.now - 1.minute }
  let(:long_past) { Time.now - 2.hours }

  describe 'POST /readings' do
    context 'when setting time explicitly' do
      it 'uses current time by default' do
        expect(sensor.readings.count).to eq 0
        post readings_path, token: sensor.token, measurement.name => 2.5
        expect(sensor.readings.count).to eq 1
        expect(sensor.readings[0].time).to be_within(1.second).of(Time.now)
      end

      it 'uses time provided through the parameter' do
        expect(sensor.readings.count).to eq 0
        post readings_path, token: sensor.token, measurement.name => 2.5, time: Time.now - 34.minutes
        expect(sensor.readings.count).to eq 1
        expect(sensor.readings[0].time).to be_within(1.second).of(Time.now - 34.minutes)
      end

      it 'support well-specified format for date and time' do
        post readings_path, token: sensor.token, measurement.name => 2.5, time: '2016-01-19T11:10:15UTC'
        expect(response).to be_success
        expect(sensor.readings.count).to eq 1
        db_date = Reading.connection.execute('SELECT * FROM readings').to_a[0]['time']
        expect(db_date).to eq '2016-01-19 11:10:15'
        expect(sensor.readings[0].time).to eq Time.utc(2016, 01, 19, 11, 10, 15)
      end

      it 'support nonUTC time zone declaration for date and time' do
        post readings_path, token: sensor.token, measurement.name => 2.5, time: '2016-01-19T11:10:15CET'
        expect(response).to be_success
        expect(sensor.readings.count).to eq 1
        db_date = Reading.connection.execute('SELECT * FROM readings').to_a[0]['time']
        expect(db_date).to eq '2016-01-19 10:10:15'
        expect(sensor.readings[0].time).to eq Time.utc(2016, 01, 19, 10, 10, 15)
      end

      it 'assumes UTC when no time zone is provided' do
        post readings_path, token: sensor.token, measurement.name => 2.5, time: '2016-01-19T11:10:15'
        expect(response).to be_success
        expect(sensor.readings.count).to eq 1
        db_date = Reading.connection.execute('SELECT * FROM readings').to_a[0]['time']
        expect(db_date).to eq '2016-01-19 11:10:15'
        expect(sensor.readings[0].time).to eq Time.utc(2016, 01, 19, 11, 10, 15)
      end
    end
  end

  describe 'GET /readings.csv' do
    context 'when a sensor has no readings' do
      it 'produces a no-reading document' do
        get readings_path, sensor_id: sensor.id, format: :csv
        expect(response).to be_success
        expect(response.body.lines[0].strip).to eq 'Sensor id,Measurement name'
        expect(response.body.lines[1].strip).to eq "#{sensor.id},#{measurement.name}"
      end
    end

    context 'when a sensor has multiple series' do
      before(:each) do
        sensor.measurements << other_measurement
      end

      it 'aligns readings according to time' do
        sensor.readings << create(:reading, measurement: measurement, value: 2, time: past)
        sensor.readings << create(:reading, measurement: measurement, value: 3, time: now)
        sensor.readings << create(:reading, measurement: measurement, value: 1, time: long_past)
        sensor.readings << create(:reading, measurement: other_measurement, value: 5, time: past)
        sensor.readings << create(:reading, measurement: other_measurement, value: 4, time: long_past)
        sensor.readings << create(:reading, measurement: other_measurement, value: 6, time: now)
        expect(sensor.reload.readings.count).to eq 6

        get readings_path, sensor_id: sensor.id, format: :csv
        expect(response).to be_success
        expect(response.body.lines.size).to eq 3
        expected = ["#{sensor.id},#{measurement.name},1.0,2.0,3.0", "#{sensor.id},#{other_measurement.name},4.0,5.0,6.0"]
        expect(expected).to include response.body.lines[1].strip
        expect(expected).to include response.body.lines[2].strip
      end

      it 'properly handles sparse data' do
        sensor.readings << create(:reading, measurement: measurement, value: 3, time: now)
        sensor.readings << create(:reading, measurement: measurement, value: 1, time: long_past)
        sensor.readings << create(:reading, measurement: other_measurement, value: 5, time: past)
        sensor.readings << create(:reading, measurement: other_measurement, value: 4, time: long_past)
        expect(sensor.reload.readings.count).to eq 4

        get readings_path, sensor_id: sensor.id, format: :csv
        expect(response).to be_success
        expect(response.body.lines.size).to eq 3
        expected = ["#{sensor.id},#{measurement.name},1.0,,3.0", "#{sensor.id},#{other_measurement.name},4.0,5.0,"]
        expect(expected).to include response.body.lines[1].strip
        expect(expected).to include response.body.lines[2].strip
        puts response.body.lines[0]
      end
    end
  end
end
