class MeasurementSensor < ActiveRecord::Base
  belongs_to :measurement
  belongs_to :sensor

  validates :measurement, :sensor, presence: true
end
