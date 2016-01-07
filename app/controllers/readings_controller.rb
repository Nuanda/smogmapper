class ReadingsController < ApplicationController
  layout false
  skip_before_action :verify_authenticity_token

  def create
    if demo?
      head 501, content_type: "text/html"
    else
      @sensor = Sensor.find_by_token(params[:token])

      if @sensor
        humidity = Measurement.find_by_name('humidity')
        temperature = Measurement.find_by_name('temperature')
        pm = Measurement.find_by_name('pm')

        # pm_value = (params[:pm].to_f / 1024) * 500
        pm_value = params[:pm].to_f  # Let's record raw data

        Reading.create(value: params[:humidity].to_f, sensor: @sensor, measurement: humidity, time: Time.now)
        Reading.create(value: params[:temperature].to_f, sensor: @sensor, measurement: temperature, time: Time.now)
        Reading.create(value: pm_value, sensor: @sensor, measurement: pm, time: Time.now)

        head :ok
      else
        head 403, content_type: "text/html"
      end
    end
  end
end
