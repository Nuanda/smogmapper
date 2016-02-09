class SensorsController < ApplicationController
  layout false

  def show
    @sensor = Sensor.find(params[:id])

    Rails.logger.info "FROM: #{from}, TO: #{to}"

    @readings = @sensor.readings.includes(:measurement).
                where('time > ? AND time <= ?', from, to).
                order('time asc').
                group_by { |r| r.measurement }

    @readings = @readings.sort_by{ |m| measurement_order.index m[0].name }

    @locations = @sensor.locations.
                 where('registration_time > ? AND registration_time <= ?', from, to).
                 order('registration_time asc')

    render partial: 'sensors/show'
  end

  def index
    render json: Sensor.with_last_location.to_json
  end

  private

  def to
    @to ||= if demo?
              (params[:id].to_i == 1000) ? Time.new(2015, 12, 13, 15, 15) : Time.new(2015, 12, 14, 10, 34)
            else
              Time.now
            end
  end

  def from
    @from ||= to - interval
  end

  def interval
    @interval ||= Rails.application.config_for(:application).
                        fetch('charts', { 'interval' => 5 })['interval'].hours
  end

  def measurement_order
    %w(pm pm1 pm2_5 pm10 temperature humidity)
  end
end
