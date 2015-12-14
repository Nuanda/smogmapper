class ReadingsController < ApplicationController
  layout false

  def show
    # NOTE: blocked for demo mode
    # @sensor = Sensor.find(params[:id])
    #
    # humidity = Measurement.find_by_name('humidity')
    # temperature = Measurement.find_by_name('temperature')
    # pm = Measurement.find_by_name('pm')
    #
    # pm_value = (params[:pm].to_f / 1024) * 500
    #
    # Reading.create(value: params[:humidity].to_f, sensor: @sensor, measurement: humidity, time: Time.now)
    # Reading.create(value: params[:temp].to_f, sensor: @sensor, measurement: temperature, time: Time.now)
    # Reading.create(value: pm_value, sensor: @sensor, measurement: pm, time: Time.now)

    head 200, content_type: "text/html"
  end
end
