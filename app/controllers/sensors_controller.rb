class SensorsController < ApplicationController
  layout false

  def show
    @sensor = Sensor.find(params[:id])

    @readings = @sensor.
      readings.
      where('time > ?', Time.now - 1.day).
      includes(:measurement).
      order('time asc').
      group_by{ |r| r.measurement }

    render partial: 'sensors/show'
  end

  def index
    @sensors = Sensor.includes(:measurements).all

    render json: @sensors
  end
end
