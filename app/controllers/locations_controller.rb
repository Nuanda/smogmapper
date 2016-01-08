class LocationsController < ApplicationController
  layout false

  def new
    @location = Location.new

    render partial: 'locations/new'
  end
end
