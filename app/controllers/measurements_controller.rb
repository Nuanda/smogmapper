class MeasurementsController < ApplicationController
  layout false

  def show
    @measurement = Measurement.find(params[:id])
    @readings = @measurement.
      readings.
      where('time > ?', Time.now - 1.hour).
      group_by{ |r| ((Time.now - r.time) / 15.minutes).to_i }

    render json: @readings, include: :sensor
  end
end
