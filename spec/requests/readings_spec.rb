require 'rails_helper'

RSpec.describe "Readings" do
  let(:measurement) { create(:measurement) }
  let(:sensor) { create(:sensor, measurements: [measurement]) }

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
end
