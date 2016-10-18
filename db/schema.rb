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

ActiveRecord::Schema.define(version: 20161018220746) do

  create_table "lines", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "prefs", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "name_roma",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "station_lines", force: :cascade do |t|
    t.integer  "station_id", limit: 4
    t.integer  "line_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "station_lines", ["line_id"], name: "index_station_lines_on_line_id", using: :btree
  add_index "station_lines", ["station_id"], name: "index_station_lines_on_station_id", using: :btree

  create_table "stations", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "name_orig",    limit: 255
    t.string   "name_kana",    limit: 255
    t.string   "url",          limit: 255
    t.string   "lat",          limit: 255
    t.string   "lon",          limit: 255
    t.integer  "pref_id",      limit: 4
    t.string   "map_url",      limit: 255
    t.string   "weather_url",  limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "nandoku_flag",             default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "scname",        limit: 255
    t.string   "name",          limit: 255
    t.boolean  "weather_flag"
    t.string   "siritori_word", limit: 255
    t.integer  "siritori_cnt",  limit: 4,   default: 0
    t.integer  "nandoku_cnt",   limit: 4
    t.integer  "station_id",    limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_foreign_key "station_lines", "lines"
  add_foreign_key "station_lines", "stations"
end
