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

ActiveRecord::Schema.define(:version => 20110825195412) do

  create_table "count_sessions", :force => true do |t|
    t.integer  "segment_id"
    t.datetime "start"
    t.datetime "stop"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "count_sessions", ["segment_id"], :name => "index_count_sessions_on_segment_id"

  create_table "counts", :force => true do |t|
    t.integer  "count_session_id"
    t.datetime "at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "counts", ["count_session_id"], :name => "index_counts_on_count_session_id"

  create_table "data_sources", :force => true do |t|
    t.string   "name"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geo_points", :force => true do |t|
    t.decimal  "latitude",       :precision => 15, :scale => 10
    t.decimal  "longitude",      :precision => 15, :scale => 10
    t.decimal  "accuracy",       :precision => 5,  :scale => 2
    t.integer  "data_source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_points", ["data_source_id"], :name => "index_geo_points_on_data_source_id"

  create_table "ped_projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scenarios", :force => true do |t|
    t.integer  "ped_project_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scenarios", ["ped_project_id"], :name => "index_scenarios_on_ped_project_id"

  create_table "segment_in_scenarios", :force => true do |t|
    t.integer  "scenario_id"
    t.integer  "segment_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "segment_in_scenarios", ["scenario_id"], :name => "index_segment_in_scenarios_on_scenario_id"
  add_index "segment_in_scenarios", ["segment_id"], :name => "index_segment_in_scenarios_on_segment_id"

  create_table "segments", :force => true do |t|
    t.integer  "ped_project_id"
    t.integer  "geopoint_a_id"
    t.integer  "geopoint_b_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "segments", ["geopoint_a_id"], :name => "index_segments_on_geopoint_a_id"
  add_index "segments", ["geopoint_b_id"], :name => "index_segments_on_geopoint_b_id"
  add_index "segments", ["ped_project_id"], :name => "index_segments_on_ped_project_id"

end
