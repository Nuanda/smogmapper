class ReadingsController < ApplicationController
  layout false

  def show
    @sensor = Sensor.find(params[:id])

    humidity = Measurement.find_by_name('humidity')
    temperature = Measurement.find_by_name('temperature')
    pm = Measurement.find_by_name('pm')

    Reading.create(value: params[:humidity].to_f, sensor: @sensor, measurement: humidity, time: Time.now)
    Reading.create(value: params[:temperature].to_f, sensor: @sensor, measurement: temperature, time: Time.now)
    Reading.create(value: params[:pm].to_f, sensor: @sensor, measurement: pm, time: Time.now)

    head 200, content_type: "text/html"
  end
end
