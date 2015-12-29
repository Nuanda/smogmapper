class SensorsController < ApplicationController
  layout false

  def show
    @sensor = Sensor.find(params[:id])
    ref_time = Rails.env.production? ? Time.new(2015, 12, 14, 10, 34) : Time.now

    @readings = @sensor.
      readings.
      where('time > ?', ref_time - 1.day).
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
