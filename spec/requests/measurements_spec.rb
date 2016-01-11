require 'rails_helper'

RSpec.describe "Measurements" do

  context 'validate selection of readings and coordinates' do

    let(:s1) { create(:sensor) }
    let(:s2) { create(:sensor) }

    let(:m_long_past) {
      create(
          :measurement,
          sensors: [s1, s2],
          created_at: Time.now - 1.day
      )
    }

    let(:m_past) {
      create(
        :measurement,
        sensors: [s1, s2],
        created_at: Time.now - 1.hour
      )
    }

    let(:m_present) {
      create(
          :measurement,
          sensors: [s1, s2],
          created_at: Time.now
      )
    }

    let(:m_future) {
      create(
          :measurement,
          sensors: [s1, s2],
          created_at: Time.now + 1.hour
      )
    }

    it 'returns an empty set when no readings qualify' do

      r1 = create(:reading, sensor: s1, value: 1.0, measurement: m_future, time: m_future.created_at)
      r2 = create(:reading, sensor: s2, value: 1.5, measurement: m_future, time: m_future.created_at)
      l1 = create(:location, sensor: s1, longitude: 100, latitude: 100, registration_time: Time.now-1.hour)
      l2 = create(:location, sensor: s2, longitude: 110, latitude: 110, registration_time: Time.now-1.hour)

      get "/measurements/show"

      expect(response.status).to eq 200
      expect(JSON.parse(response.body)).to eq []
    end

    it 'returns an empty set when no locations qualify' do
      r1 = create(:reading, sensor: s1, value: 1.0, measurement: m_past, time: m_past.created_at)
      r2 = create(:reading, sensor: s2, value: 1.5, measurement: m_past, time: m_past.created_at)
      l1 = create(:location, sensor: s1, longitude: 100, latitude: 100, registration_time: m_future.created_at)
      l2 = create(:location, sensor: s2, longitude: 110, latitude: 110, registration_time: m_future.created_at)

      get "/measurements/show"

      expect(response.status).to eq 200
      expect(JSON.parse(response.body)).to eq []
    end

    it 'returns the latest readings which qualify' do
      r0 = create(:reading, sensor: s1, value: 0.5, measurement: m_long_past, time: m_long_past.created_at)
      r1 = create(:reading, sensor: s1, value: 1.0, measurement: m_past, time: m_past.created_at)
      r2 = create(:reading, sensor: s1, value: 1.5, measurement: m_present, time: m_present.created_at)
      r3 = create(:reading, sensor: s1, value: 2.0, measurement: m_future, time: m_future.created_at)
      l1 = create(:location, sensor: s1, longitude: 100, latitude: 100, registration_time: m_long_past.created_at)

      get "/measurements/show"

      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.length).to eq 1
      expect(body.first['value']).to eq 1.5
    end

    it 'returns the latest locations which qualify' do
      r1 = create(:reading, sensor: s1, value: 1.0, measurement: m_past, time: m_past.created_at)
      r2 = create(:reading, sensor: s1, value: 1.5, measurement: m_present, time: m_present.created_at)
      r3 = create(:reading, sensor: s1, value: 2.0, measurement: m_future, time: m_future.created_at)
      l1 = create(:location, sensor: s1, longitude: 100, latitude: 100, registration_time: m_long_past.created_at)
      l2 = create(:location, sensor: s1, longitude: 120, latitude: 120, registration_time: m_past.created_at)
      l3 = create(:location, sensor: s1, longitude: 140, latitude: 140, registration_time: m_present.created_at)
      l4 = create(:location, sensor: s1, longitude: 160, latitude: 160, registration_time: m_future.created_at)

      get "/measurements/show"

      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.length).to eq 1
      expect(body.first['longitude']).to eq 140
      expect(body.first['latitude']).to eq 140
    end

    it 'properly handles multiple readings' do
      r1 = create(:reading, sensor: s1, value: 1.0, measurement: m_long_past, time: m_long_past.created_at)
      r2 = create(:reading, sensor: s1, value: 1.5, measurement: m_past, time: m_past.created_at)
      r3 = create(:reading, sensor: s1, value: 2.0, measurement: m_present, time: m_present.created_at)
      r4 = create(:reading, sensor: s2, value: 4.0, measurement: m_past, time: m_past.created_at)
      r2 = create(:reading, sensor: s2, value: 4.5, measurement: m_present, time: m_present.created_at)
      r3 = create(:reading, sensor: s2, value: 5.0, measurement: m_future, time: m_future.created_at)
      l2 = create(:location, sensor: s1, longitude: 120, latitude: 120, registration_time: m_past.created_at)
      l2 = create(:location, sensor: s2, longitude: 140, latitude: 140, registration_time: m_past.created_at)
      l3 = create(:location, sensor: s2, longitude: 160, latitude: 160, registration_time: m_present.created_at)
      l4 = create(:location, sensor: s2, longitude: 180, latitude: 180, registration_time: m_future.created_at)

      get "/measurements/show"

      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.length).to eq 2
      expect(body.first['longitude']).to eq 120
      expect(body.first['latitude']).to eq 120
      expect(body.first['value']).to eq 2.0
      expect(body.second['longitude']).to eq 160
      expect(body.second['latitude']).to eq 160
      expect(body.second['value']).to eq 4.5
    end

  end

end
