class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.string :name, null:false
      t.string :unit, null:false

      t.timestamps null: false
    end
  end
end
