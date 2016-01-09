class SensorsController < ApplicationController
  layout false

  def show
    @sensor = Sensor.find(params[:id])

    Rails.logger.info "FROM: #{from}, TO: #{to}"

    @readings = @sensor.readings.includes(:measurement).
                where('time > ? AND time <= ?', from, to).
                order('time asc').
                group_by { |r| r.measurement }

    render partial: 'sensors/show'
  end

  def index
    last_location_joins = <<-SQL
      JOIN locations l1 ON(l1.sensor_id = sensors.id)
      LEFT OUTER JOIN locations l2 ON (sensors.id = l2.sensor_id AND
        (l1.registration_time < l2.registration_time OR
         l1.registration_time = l2.registration_time AND l1.id < l2.id))
    SQL

    render json: Sensor.joins(last_location_joins).
      where('l2.id IS NULL').
      select('sensors.id, l1.latitude, l1.longitude').
      to_json
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
    Rails.application.config_for(:application).
      fetch('charts', { 'interval' => 5 })['interval'].hours
  end
end
