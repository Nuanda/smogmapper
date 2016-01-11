class MeasurementsController < ApplicationController
  layout false

  def show
    if params[:iteration].blank?
      last_reading_time = Reading.where(measurement_id: params[:id]).
                          maximum(:time)
      last_reading_time = Time.now if last_reading_time.blank? || (last_reading_time > Time.now)
      readings = readings_json(last_reading_time + 1.second, (2 * interval).minutes)
    else
      to = reference_time - (params[:iteration].to_i * interval).minutes
      readings = readings_json(to, 25.hours)
    end

    render json: readings
  end

  private

  def readings_json(to, expires_in)
    cache_key = { id: params[:id], to: to&.to_f }

    readings = Rails.cache.fetch(cache_key, expires_in: expires_in) do
      inner_query = <<-SQL
        SELECT DISTINCT ON (sensor_id)
        id, sensor_id, latitude, longitude, registration_time
        FROM locations
        WHERE registration_time <= #{ActiveRecord::Base::sanitize(to.utc.to_s(:db))}
        ORDER BY sensor_id, registration_time DESC, id
      SQL

      outer_query = <<-SQL
        SELECT DISTINCT ON (r.sensor_id)
        r.value, loc.longitude, loc.latitude
        FROM readings r
        JOIN (#{inner_query}) loc ON loc.sensor_id = r.sensor_id
        WHERE r.time <= #{ActiveRecord::Base::sanitize(to.utc.to_s(:db))}
        AND r.measurement_id = #{ActiveRecord::Base::sanitize(params[:id])}
        ORDER BY r.sensor_id, r.time DESC
      SQL

      Reading.find_by_sql(outer_query)
    end
    readings.to_json(only: [:value, :longitude, :latitude])
  end

  def interval_number(time)
    minutes = (time.getutc.seconds_since_midnight/60).to_i
    logger.info "MINUTES: #{minutes}"
    (minutes/15).to_i
  end

  def reference_time
    @reference_time ||= begin
      Time.utc(base_time.year, base_time.month, base_time.day) +
        (interval_number(base_time) * interval).minutes
    end
  end

  def base_time
    demo? ? Time.new(2015, 12, 14, 10, 34) : Time.now
  end

  def interval
    Rails.application.config_for(:application).
      fetch('measurements', { 'interval' => 15 })['interval']
  end
end
