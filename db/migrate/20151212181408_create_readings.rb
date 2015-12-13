class CreateReadings < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.belongs_to :measurement, null: false, index: true, foreign_key: true
      t.belongs_to :sensor, null: false, index: true, foreign_key: true
      t.float :value, null: false
      t.timestamp :time, null: true

      t.timestamps null: false
    end
  end
end
