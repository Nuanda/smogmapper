class CreateLocations < ActiveRecord::Migration
  def up
    create_table :locations do |t|
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.float :height
      t.timestamp :registration_time, null: true, index: true
      t.belongs_to :sensor, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end

    Location.reset_column_information

    Sensor.find_each do |sensor|
      Location.create(longitude: sensor.long, latitude: sensor.lat, sensor: sensor)
    end

    remove_column :sensors, :long
    remove_column :sensors, :lat
  end
end
