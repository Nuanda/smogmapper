class MeasurementsController < ApplicationController
  layout false

  def show
    if params[:iteration].blank?
      readings = readings_json(last_reading_time + 1.second, Time.current,
                               last_reading_expires_in)
    else
      to = reference_time - (params[:iteration].to_i * interval).minutes
      readings = readings_json(to, to, 25.hours)
    end

    render json: readings
  end

  private

  def readings_json(key_date, to, expires_in)
    cache_key = { id: params[:id], to: key_date&.to_f }

    Rails.cache.fetch(cache_key, expires_in: expires_in) do
      Reading.values_with_location(to - interval.minutes, to, params[:id]).
        to_json(only: [:value, :longitude, :latitude])
    end
  end

  def last_reading_expires_in
    first_reading_time = Reading.
                         where('measurement_id = ? AND time > ?',
                               params[:id], Time.current - interval.minutes).
                         minimum(:time)
    first_reading_time = (2 * interval).minutes.ago unless first_reading_time

    interval.minutes - (Time.current - first_reading_time).seconds
  end

  def last_reading_time
    @last_reading_time ||= begin
      time = Reading.where(measurement_id: params[:id]).maximum(:time)
      time&.past? ? time : Time.now
    end
  end

  def interval_number(time)
    minutes = (time.getutc.seconds_since_midnight/60).to_i
    logger.info "MINUTES: #{minutes}"
    (minutes/15).to_i
  end

  def reference_time
    @reference_time ||=
      Time.utc(base_time.year, base_time.month, base_time.day) +
        (interval_number(base_time) * interval).minutes
  end

  def base_time
    demo? ? Time.new(2015, 12, 14, 10, 34) : Time.now
  end

  def interval
    Rails.application.config_for(:application).
      fetch('measurements', { 'interval' => 15 })['interval']
  end
end
