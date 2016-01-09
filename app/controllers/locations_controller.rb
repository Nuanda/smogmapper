class LocationsController < ApplicationController
  layout false

  def new
    @location = Location.new
    @location.sensor = Sensor.new

    render partial: 'locations/new'
  end

  def create
    @sensor = Sensor.find_by_token(params[:location][:sensor][:token])

    if @sensor
      @location = Location.create(
        location_params.merge(
          sensor: @sensor,
          registration_time: Time.now
        )
      )
    else
      @location = Location.new(location_params)
      @location.sensor = Sensor.new
      @location.sensor.errors.add(:token, :incorrect)

      render partial: 'locations/new'
    end
  end

  private

  def create_params
    params.require(:location).permit(:longitude, :latitude, :height, sensor: [:token, :name])
  end

  def location_params
    filtered_params = create_params
    {
      longitude: filtered_params[:longitude],
      latitude: filtered_params[:latitude],
      height: filtered_params[:height]
    }
  end
end
