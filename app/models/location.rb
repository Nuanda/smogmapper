class Location < ActiveRecord::Base
  belongs_to :sensor

  validates :latitude, :longitude, :sensor, presence: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  before_create :set_registration_time

  private

  def set_registration_time
    self.registration_time = Time.now
    if sensor.locations.count == 0 && sensor.readings.count > 0
      self.registration_time = sensor.readings.minimum(:time) - 1.minute
    end
  end
end
