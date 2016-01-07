class Location < ActiveRecord::Base
  belongs_to :sensor

  validates :latitude, :longitude, :sensor, presence: true
end
