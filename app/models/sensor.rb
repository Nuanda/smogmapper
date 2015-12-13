class Sensor < ActiveRecord::Base
  has_many :readings, dependent: :destroy
  has_many :measurement_sensors, dependent: :destroy
  has_many :measurements, through: :measurement_sensors

  validates :long, :lat, presence: true
end
