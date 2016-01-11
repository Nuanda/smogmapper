require 'rails_helper'

RSpec.describe "Measurements" do

  context 'validate selection of readings and coordinates' do

    let(:s1) { create(:sensor) }
    let(:s2) { create(:sensor) }

    let(:pm) {
      create(
        :measurement,
        name: 'pm',
        sensors: [s1, s2]
      )
    }

    let(:future) { Time.now + 1.hour }
    let(:past) { Time.now - 1.hour }
    let(:long_past) { Time.now - 1.day }
    let(:present) { Time.now }

    # let(:m_long_past) {
    #   create(
    #       :measurement,
    #       sensors: [s1, s2],
    #       created_at: Time.now - 1.day
    #   )
    # }
    #
    # let(:m_past) {
    #   create(
    #     :measurement,
    #     sensors: [s1, s2],
    #     created_at: Time.now - 1.hour
    #   )
    # }
    #
    # let(:m_present) {
    #   create(
    #       :measurement,
    #       sensors: [s1, s2],
    #       created_at: Time.now
    #   )
    # }
    #
    # let(:m_future) {
    #   create(
    #       :measurement,
    #       sensors: [s1, s2],
    #       created_at: Time.now + 1.hour
    #   )
    # }

    it 'returns an empty set when no readings qualify' do

      r1 = create(:reading, sensor: s1, value: 1.0, measurement: pm, time: future)
      r2 = create(:reading, sensor: s2, value: 1.5, measurement: pm, time: future)
      l1 = create(:location, sensor: s1, longitude: 100, latitude: 60, registration_time: Time.now - 1.hour)
      l2 = create(:location, sensor: s2, longitude: 110, latitude: 70, registration_time: Time.now - 1.hour)

      get "/measurements/#{pm.id}"

      expect(response.status).to eq 200
      expect(JSON.parse(response.body)).to eq []
    end

    it 'returns an empty set when no locations qualify' do
      r1 = create(:reading, sensor: s1, value: 1.0, measurement: pm, time: past)
      r2 = create(:reading, sensor: s2, value: 1.5, measurement: pm, time: past)
      l1 = create(:location, sensor: s1, longitude: 100, latitude: 60, registration_time: future)
      l2 = create(:location, sensor: s2, longitude: 110, latitude: 70, registration_time: future)

      get "/measurements/#{pm.id}"

      expect(response.status).to eq 200
      expect(JSON.parse(response.body)).to eq []
    end

    it 'returns the latest readings which qualify' do
      r0 = create(:reading, sensor: s1, value: 0.5, measurement: pm, time: long_past)
      r1 = create(:reading, sensor: s1, value: 1.0, measurement: pm, time: past)
      r2 = create(:reading, sensor: s1, value: 1.5, measurement: pm, time: present)
      r3 = create(:reading, sensor: s1, value: 2.0, measurement: pm, time: future)
      l1 = create(:location, sensor: s1, longitude: 100, latitude: 60, registration_time: long_past)

      get "/measurements/#{pm.id}"

      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.length).to eq 1
      expect(body.first['value']).to eq 1.5
    end

    it 'returns the latest locations which qualify' do
      r1 = create(:reading, sensor: s1, value: 1.0, measurement: pm, time: past)
      r2 = create(:reading, sensor: s1, value: 1.5, measurement: pm, time: present)
      r3 = create(:reading, sensor: s1, value: 2.0, measurement: pm, time: future)
      l1 = create(:location, sensor: s1, longitude: 100, latitude: 60, registration_time: long_past)
      l2 = create(:location, sensor: s1, longitude: 120, latitude: 80, registration_time: past)
      l3 = create(:location, sensor: s1, longitude: 140, latitude: 30, registration_time: present)
      l4 = create(:location, sensor: s1, longitude: 160, latitude: 20, registration_time: future)

      get "/measurements/#{pm.id}"

      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.length).to eq 1
      expect(body.first['longitude']).to eq 140
      expect(body.first['latitude']).to eq 30
    end

    it 'properly handles multiple readings' do
      r1 = create(:reading, sensor: s1, value: 1.0, measurement: pm, time: long_past)
      r2 = create(:reading, sensor: s1, value: 1.5, measurement: pm, time: past)
      r3 = create(:reading, sensor: s1, value: 2.0, measurement: pm, time: present)
      r4 = create(:reading, sensor: s2, value: 4.0, measurement: pm, time: past)
      r2 = create(:reading, sensor: s2, value: 4.5, measurement: pm, time: present)
      r3 = create(:reading, sensor: s2, value: 5.0, measurement: pm, time: future)
      l2 = create(:location, sensor: s1, longitude: 120, latitude: 80, registration_time: past)
      l2 = create(:location, sensor: s2, longitude: 140, latitude: 90, registration_time: past)
      l3 = create(:location, sensor: s2, longitude: 160, latitude: 30, registration_time: present)
      l4 = create(:location, sensor: s2, longitude: 180, latitude: 40, registration_time: future)

      get "/measurements/#{pm.id}"

      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.length).to eq 2
      expect(body.first['longitude']).to eq 120
      expect(body.first['latitude']).to eq 80
      expect(body.first['value']).to eq 2.0
      expect(body.second['longitude']).to eq 160
      expect(body.second['latitude']).to eq 30
      expect(body.second['value']).to eq 4.5
    end

  end

end
