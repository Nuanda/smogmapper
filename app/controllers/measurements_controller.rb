class MeasurementsController < ApplicationController
  layout false

  def show
    if params[:iteration].blank?
      last_reading_time = Reading.where(measurement_id: params[:id]).
                          maximum(:time)
      readings = readings_json((last_reading_time || Time.now),
                               (2 * interval).minutes)
    else
      to = reference_time - (params[:iteration].to_i * interval).minutes
      readings = readings_json(to, 25.hours)
    end

    render json: readings
  end

  private

  def readings_json(to, expires_in)
    cache_key = { id: params[:id], to: to&.to_f }

    Rails.cache.fetch(cache_key, expires_in: expires_in) do
      Reading.includes(:sensor).
        where(measurement_id: params[:id]).
        where('time > ? AND time <= ?', to - interval.minutes, to).
        to_json(only: :value, include: { sensor: { only: [:lat, :long] } })
    end
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
