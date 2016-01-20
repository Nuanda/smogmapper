class Reading < ActiveRecord::Base
  belongs_to :sensor
  belongs_to :measurement

  validates :value, :sensor, :time, :measurement, presence: true

  #
  # Get last measurement readings with their location in defined date
  # interval.
  #
  # Example:
  #   `Measurement.values_with_location(15.minutes.ago, Time.now, 1).to_json`
  #   => [{"value": 1.0, "latitude": 50.0, "longitude": 20.0}, ...]
  #
  def self.values_with_location(from_date, to_date, measurement_id)
    query = <<-SQL
      SELECT DISTINCT ON (r.sensor_id)
        r.value, loc.longitude, loc.latitude
      FROM readings r
      JOIN (
        SELECT DISTINCT ON (sensor_id)
          id, sensor_id, latitude, longitude, registration_time
        FROM locations
        WHERE registration_time <= :to_date
        ORDER BY sensor_id, registration_time DESC, id
      ) loc ON loc.sensor_id = r.sensor_id
      WHERE r.time <= :to_date AND
            r.time > :from_date AND
            r.measurement_id = :measurement_id
      ORDER BY r.sensor_id, r.time DESC
    SQL

    Reading.find_by_sql([query, { from_date: from_date,
                                  to_date: to_date,
                                  measurement_id: measurement_id }])
  end
end
