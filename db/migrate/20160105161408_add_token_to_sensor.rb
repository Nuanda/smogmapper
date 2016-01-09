class AddTokenToSensor < ActiveRecord::Migration
  def change
    add_column :sensors, :token, :text, index: true

    Sensor.reset_column_information

    Sensor.find_each do |sensor|
      sensor.update_column(:token, SecureRandom.urlsafe_base64.gsub('-_','')[0,12])
    end

    change_column_null :sensors, :token, false
  end
end
