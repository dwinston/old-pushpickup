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

ActiveRecord::Schema.define(:version => 20130404233410) do

  create_table "availabilities", :force => true do |t|
    t.datetime "start_time"
    t.integer  "player_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "duration"
  end

  add_index "availabilities", ["player_id", "start_time"], :name => "index_availabilities_on_player_id_and_start_time"

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "fields", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "street_address"
    t.string   "zip_code"
    t.integer  "city_id"
  end

  create_table "fieldslots", :force => true do |t|
    t.integer  "availability_id"
    t.integer  "field_id"
    t.boolean  "open",            :default => true
    t.string   "why_not_open"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "fieldslots", ["open"], :name => "index_fieldslots_on_open"

  create_table "games", :force => true do |t|
    t.datetime "start_time"
    t.integer  "duration"
    t.integer  "field_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "games_players", :id => false, :force => true do |t|
    t.integer "game_id"
    t.integer "player_id"
  end

  create_table "needs", :force => true do |t|
    t.string   "name"
    t.integer  "player_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "value"
  end

  add_index "needs", ["player_id"], :name => "index_needs_on_player_id"

  create_table "players", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",                      :default => false
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean  "activated",                  :default => false
    t.string   "email_confirmation_token"
    t.datetime "email_confirmation_sent_at"
  end

  add_index "players", ["email"], :name => "index_players_on_email", :unique => true
  add_index "players", ["remember_token"], :name => "index_players_on_remember_token"

end
