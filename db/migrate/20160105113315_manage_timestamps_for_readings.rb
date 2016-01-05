class ManageTimestampsForReadings < ActiveRecord::Migration
  def change
    remove_timestamps :readings
    add_index :readings, :time
  end
end
