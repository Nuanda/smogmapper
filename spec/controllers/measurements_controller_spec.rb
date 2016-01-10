require 'rails_helper'

RSpec.describe MeasurementsController, :type => :controller do

  context 'proper selection of locations for measurements' do

    it 'selects most current measurement together with location info' do

      s1 = create(:sensor)
      s2 = create(:sensor)
      s3 = create(:sensor)
      s4 = create(:sensor)

      m_v_old = create(
          :measurement,
          sensors: [s1, s2, s3, s4],
          created_at: Time.now - 120.minutes
      )

      m_old = create(
        :measurement,
        sensors: [s1, s2, s3, s4],
        created_at: Time.now - 20.minutes
      )

      m_new = create(
        :measurement,
        sensors: [s1, s2, s3, s4],
        created_at: Time.now + 20.minutes
      )

      r1_v_old = create(:reading, measurement: m_v_old, sensor: s1, value: 0.1)
      r2_v_old = create(:reading, measurement: m_v_old, sensor: s2, value: 0.2)
      r3_v_old = create(:reading, measurement: m_v_old, sensor: s3, value: 0.3)
      r4_v_old = create(:reading, measurement: m_v_old, sensor: s4, value: 0.4)

      r1_old = create(:reading, measurement: m_old, sensor: s1, value: 1.0)
      r2_old = create(:reading, measurement: m_old, sensor: s2, value: 1.5)
      r3_old = create(:reading, measurement: m_old, sensor: s3, value: 2.0)
      r4_old = create(:reading, measurement: m_old, sensor: s4, value: 2.5)

      r1_new = create(:reading, measurement: m_old, sensor: s1, value: 5.0)
      r2_new = create(:reading, measurement: m_new, sensor: s2, value: 6.5)
      r3_new = create(:reading, measurement: m_new, sensor: s3, value: 8.0)
      r4_new = create(:reading, measurement: m_new, sensor: s4, value: 9.5)

      l1a = create(
        :location,
        sensor: s1,
        registration_time: Time.now - 20.minutes,
        latitude: 100,
        longitude: 100
      )

      l1b = create(
          :location,
          sensor: s1,
          registration_time: Time.now - 15.minutes,
          latitude: 120,
          longitude: 120
      )

      l1c = create(
          :location,
          sensor: s1,
          registration_time: Time.now + 5.minutes,
          latitude: 140,
          longitude: 140
      )

      l2a = create(
          :location,
          sensor: s2,
          registration_time: Time.now - 12.minutes,
          latitude: 100,
          longitude: 100
      )

      l3a = create(
          :location,
          sensor: s3,
          registration_time: Time.now + 2.minutes,
          latitude: 300,
          longitude: 300
      )

      result1 = JSON.parse MeasurementsController.new
        .send(:readings_json, (Time.now - 10.minutes).utc, 0)
      expect(result1.length).to eq 2
      expect(result1.first['longitude']).to eq 120
      expect(result1.first['value']).to eq r1_old.value
      expect(result1.second['value']).to eq r2_old.value
      result2 = JSON.parse MeasurementsController.new
        .send(:readings_json, (Time.now + 10.minutes).utc, 0)
      expect(result2.length).to eq 3
      expect(result2.first['longitude']).to eq 140
      expect(result2.first['value']).to eq r1_old.value
      expect(result2.second['value']).to eq r2_old.value
      expect(result2.third['value']).to eq r3_old.value
    end

  end

end
