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

ActiveRecord::Schema.define(version: 20161023161448) do

  create_table "tweets", force: :cascade do |t|
    t.string   "tweet",      limit: 255
    t.string   "source",     limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "scname",           limit: 255
    t.string   "name",             limit: 255
    t.boolean  "weather_flag"
    t.string   "siritori_word",    limit: 255
    t.integer  "siritori_cnt",     limit: 4,   default: 0
    t.integer  "nandoku_cnt",      limit: 4,   default: 0
    t.integer  "station_id",       limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "max_siritori_cnt", limit: 4,   default: 0
    t.integer  "nandoku_id",       limit: 4
    t.string   "quiz_type",        limit: 255
    t.integer  "quiz_level",       limit: 4,   default: 0
    t.string   "quiz_condition",   limit: 255
  end

end
