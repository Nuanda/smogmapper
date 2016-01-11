class Sensor < ActiveRecord::Base
  has_many :readings, dependent: :destroy
  has_many :measurement_sensors, dependent: :destroy
  has_many :measurements, through: :measurement_sensors
  has_many :locations, dependent: :destroy

  before_create :generate_token

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64.gsub('-_','')[0,12]
  end
end
