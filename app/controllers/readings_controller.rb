class ReadingsController < ApplicationController
  layout false
  skip_before_action :verify_authenticity_token

  def create
    if demo?
      head 501, content_type: "text/html"
    else
      sensor = Sensor.find_by_token(params[:token])

      if sensor
        sensor.measurements.each do |measurement|
          if params[measurement.name].present?
            Reading.create(value: params[measurement.name].to_f, sensor: sensor, measurement: measurement, time: Time.now)
          end
        end
        head :ok
      else
        head 403, content_type: "text/html"
      end
    end
  end
end
