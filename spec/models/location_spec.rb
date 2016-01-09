require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:location) { create(:location) }

  describe '.create' do
    context 'when assigning registration time' do
      context 'for sensor with no current location' do
        it 'uses current time for no-reading sensor' do
          expect(location.registration_time).not_to be_nil
          expect(location.registration_time).to be_within(3.seconds).of(Time.now)
        end

        it 'uses pre-first-reading time for sensor with readings' do
          reading = create(:reading, time: Time.now - 3.hours)
          location = create(:location, sensor: reading.sensor)
          expect(location.registration_time).not_to be_nil
          expect(location.registration_time).to be_within(3.seconds).of(Time.now - 3.hours - 1.minute)
        end
      end

      context 'for sensor with current location' do
        it 'uses current time for no-readings sensor' do
          expect(create(:location, sensor: location.sensor).registration_time).not_to be_nil
          expect(create(:location, sensor: location.sensor).registration_time).to be_within(3.seconds).of(Time.now)
        end

        it 'uses current time for sensor with readings' do
          create(:reading, sensor: location.sensor, time: Time.now - 3.hours)
          expect(create(:location, sensor: location.sensor).registration_time).not_to be_nil
          expect(create(:location, sensor: location.sensor).registration_time).to be_within(3.seconds).of(Time.now)
        end
      end
    end
  end
end
