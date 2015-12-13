class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.string :name
      # t.point :location, geographic: true, has_z: false, srid: 4326
      t.float :long, null: false
      t.float :lat, null: false

      t.timestamps null: false
    end
  end
end
