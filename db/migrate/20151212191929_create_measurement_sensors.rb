class CreateMeasurementSensors < ActiveRecord::Migration
  def change
    create_table :measurement_sensors do |t|
      t.belongs_to :measurement, null: false, index: true, foreign_key: true
      t.belongs_to :sensor, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
