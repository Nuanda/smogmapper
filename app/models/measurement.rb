class Measurement < ActiveRecord::Base
  has_many :measurement_sensors, dependent: :destroy
  has_many :sensors, through: :measurement_sensors
  has_many :readings, dependent: :destroy

  validates :name, :unit, presence: true
end
