# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160105113315) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "measurement_sensors", force: :cascade do |t|
    t.integer  "measurement_id", null: false
    t.integer  "sensor_id",      null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "measurement_sensors", ["measurement_id"], name: "index_measurement_sensors_on_measurement_id", using: :btree
  add_index "measurement_sensors", ["sensor_id"], name: "index_measurement_sensors_on_sensor_id", using: :btree

  create_table "measurements", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "unit",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "readings", force: :cascade do |t|
    t.integer  "measurement_id", null: false
    t.integer  "sensor_id",      null: false
    t.float    "value",          null: false
    t.datetime "time"
  end

  add_index "readings", ["measurement_id"], name: "index_readings_on_measurement_id", using: :btree
  add_index "readings", ["sensor_id"], name: "index_readings_on_sensor_id", using: :btree
  add_index "readings", ["time"], name: "index_readings_on_time", using: :btree

  create_table "sensors", force: :cascade do |t|
    t.string   "name"
    t.float    "long",       null: false
    t.float    "lat",        null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "measurement_sensors", "measurements"
  add_foreign_key "measurement_sensors", "sensors"
  add_foreign_key "readings", "measurements"
  add_foreign_key "readings", "sensors"
end
