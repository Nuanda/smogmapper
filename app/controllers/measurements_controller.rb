class MeasurementsController < ApplicationController
  layout false

  def show
    @measurement = Measurement.find(params[:id])
    render json: @measurement
  end
end
