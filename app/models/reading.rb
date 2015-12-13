class Reading < ActiveRecord::Base
  belongs_to :sensor
  belongs_to :measurement

  validates :value, :sensor, :time, :measurement, presence: true
end
