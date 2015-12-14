class HomeController < ApplicationController
  def index
    @measurements = Measurement.all
  end
end
