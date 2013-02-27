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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130226202301) do

  create_table "availabilities", :force => true do |t|
    t.datetime "start_time"
    t.integer  "player_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "duration"
  end

  add_index "availabilities", ["player_id", "start_time"], :name => "index_availabilities_on_player_id_and_start_time"

  create_table "fields", :force => true do |t|
    t.string   "name"
    t.string   "city"
    t.text     "notes"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "street_address"
    t.string   "state_abbr"
    t.string   "zip_code"
  end

  add_index "fields", ["city", "state_abbr"], :name => "index_fields_on_city_and_state_abbr"

  create_table "players", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           :default => false
  end

  add_index "players", ["email"], :name => "index_players_on_email", :unique => true
  add_index "players", ["remember_token"], :name => "index_players_on_remember_token"

end
