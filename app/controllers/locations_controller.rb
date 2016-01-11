class LocationsController < ApplicationController
  layout false

  def new
    @location = Location.new
    @location.sensor = Sensor.new

    render partial: 'locations/new'
  end

  def create
    safe_params = create_params
    @sensor = Sensor.find_by_token(safe_params[:sensor][:token])

    if @sensor
      @location = Location.new(
        location_params.merge(
          sensor: @sensor
        )
      )

      if @result = @location.save
        @sensor.update(name: safe_params[:sensor][:name]) if safe_params[:sensor][:name].present?
      end
    else
      @location = Location.new(location_params)
      @location.sensor = Sensor.new(safe_params[:sensor])
      @location.sensor.errors.add(:token, :incorrect)
    end

    render partial: 'locations/new'
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
