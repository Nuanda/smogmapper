class MeasurementsController < ApplicationController
  layout false

  def show
    @measurement = Measurement.find(params[:id])
    ref_time = Time.new(2015, 12, 14, 10, 34)
    @readings = @measurement.
      readings.
      includes(:sensor).
      where('time > ?', ref_time - ((params[:iteration].to_i + 1) * 15).minutes).
      where('time < ?', ref_time - (params[:iteration].to_i * 15).minutes)

    render json: @readings, include: :sensor
  end
end
