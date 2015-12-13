class HomeController < ApplicationController
  def index
    @measurement = Measurement.all
  end
end
