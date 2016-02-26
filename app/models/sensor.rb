class Sensor < ActiveRecord::Base
  has_many :readings, dependent: :destroy
  has_many :measurement_sensors, dependent: :destroy
  has_many :measurements, through: :measurement_sensors
  has_many :locations, dependent: :destroy

  before_create :generate_token

  enum sensor_type: [ :unknown, :reference ]

  #
  # Returns list of sensor id with its last location. Sensors without
  # location are rejected.
  #
  # Example:
  #   `Sensor.with_last_location.to_json`
  #   => [{"id": 1, "latitude": 50.0, "longitude": 20.0}, ...]
  #
  def self.with_last_location
    last_location_joins = <<-SQL
      JOIN locations l1 ON(l1.sensor_id = sensors.id)
      LEFT OUTER JOIN locations l2 ON (sensors.id = l2.sensor_id AND
        (l1.registration_time < l2.registration_time OR
         l1.registration_time = l2.registration_time AND l1.id < l2.id))
    SQL

    Sensor.joins(last_location_joins).
      where('l2.id IS NULL').
      select('sensors.id, l1.latitude, l1.longitude, sensors.sensor_type')
  end

  def current_location
    locations.order('registration_time DESC').first
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64.gsub('-_','')[0,12]
  end
end
