class MeasurementsController < ApplicationController
  layout false

  def show
    ref_time = Rails.env.production? ? Time.new(2015, 12, 14, 10, 34) : Time.now

    cache_key = { id: params[:id],
                  day: Time.now.yday,
                  interval_number: interval_number(ref_time - params[:iteration].to_i * interval) }

    @readings = Rails.cache.fetch(cache_key, expires_in: 25.hours) do
      logger.info 'MISS MISS MISS'
      @measurement = Measurement.find(params[:id])
      @measurement.
        readings.
        includes(:sensor).
        where('time > ? AND time <= ?', from, to).
        to_json(include: :sensor)
    end

    render json: @readings
  end

  private

  def interval_number(time)
    minutes = (time.seconds_since_midnight/60).to_i
    logger.info "MINUTES: #{minutes}"
    (minutes/15).to_i
  end

  def to
    ref_time = Rails.env.production? ? Time.new(2015, 12, 14, 10, 34) : Time.now
    @to ||= (ref_time - params[:iteration].to_i * interval)
  end

  def from
    @from ||= to - interval
  end

  def interval
    Rails.application.config_for(:application).
      fetch('measurements', { 'interval' => 15 })['interval'].minutes
  end
end
