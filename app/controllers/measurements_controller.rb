class MeasurementsController < ApplicationController
  layout false

  def show
    if params[:iteration].blank?
      render json: latest_readings
    else
      render json: iteration_readings
    end
  end

  private

  def latest_readings
    last_reading = Reading.where(measurement_id: params[:id]).last
    cache_key = {
      id: params[:id],
      to: last_reading.try(:time).try(:to_f)
    }
    Rails.cache.fetch(cache_key,
                      expires_in: interval + interval) do
      to = Time.now
      readings_json(to)
    end
  end

  def iteration_readings
    cache_key = {
      id: params[:id],
      day: to.yday,
      interval_number: interval_number(to)
    }

    Rails.cache.fetch(cache_key, expires_in: 25.hours) do
      readings_json(to)
    end
  end

  def readings_json(to)
    Reading.includes(:sensor).
      where(measurement_id: params[:id]).
      where('time > ? AND time <= ?', to - interval.minutes, to).
      to_json(include: :sensor)
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

  def to
    @to ||= reference_time - (params[:iteration].to_i * interval).minutes
  end

  def interval
    Rails.application.config_for(:application).
      fetch('measurements', { 'interval' => 15 })['interval']
  end
end
