class AddSensorTypeToSensors < ActiveRecord::Migration
  def change
    add_column :sensors, :sensor_type, :integer, default: 0, null: false, index: true
  end
end
