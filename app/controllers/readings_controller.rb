class ReadingsController < ApplicationController
  layout false
  skip_before_action :verify_authenticity_token

  def index
    @sensor = Sensor.find(params[:sensor_id])
    @readings = @sensor.readings.order('time asc')

    time_where_if_param('time >= ?', :from, Time.now - 1.day)
    time_where_if_param('time <= ?', :to)

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"readings-sensor-#{@sensor.id}.csv\""
        headers['Content-Type'] = 'text/csv'
      end
    end
  end

  def create
    if demo?
      head 501, content_type: "text/html"
    else
      sensor = Sensor.find_by_token(params[:token])
      time = params[:time].present? ? ActiveSupport::TimeZone.new('UTC').parse(params[:time]) : Time.now

      if sensor
        sensor.measurements.each do |measurement|
          if params[measurement.name].present?
            Reading.create(value: params[measurement.name].to_f, sensor: sensor, measurement: measurement, time: time)

            backup_config = Rails.application.config_for(:backup_server)
            if measurement.name == backup_config['measurement_name'] && sensor.id == backup_config['sensor_id']
              location = sensor.current_location
              data = "val=#{params[measurement.name].to_f}&lo=#{location.longitude}&la=#{location.latitude}"
              full_url = "#{backup_config['backup_server']}#{data}"
              logger.info "Sending data to backup URL: #{full_url}"
              `curl "#{full_url}"`
            end
          end
        end
        head :ok
      else
        head 403, content_type: "text/html"
      end
    end
  end

  private

  def time_where_if_param(sql, param_name, default = nil)
    if params[param_name].blank? && default
      @readings = @readings.where(sql, default)
    elsif params[param_name].present?
      @readings = @readings.where(sql, Time.parse(params[param_name]))
    end
  end
end

require 'csv'
