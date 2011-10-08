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

ActiveRecord::Schema.define(:version => 20111008011257) do

  create_table "count_sessions", :force => true do |t|
    t.integer  "segment_id"
    t.datetime "start"
    t.datetime "stop"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "user_id"
  end

  add_index "count_sessions", ["project_id"], :name => "index_count_sessions_on_project_id"
  add_index "count_sessions", ["segment_id"], :name => "index_count_sessions_on_segment_id"
  add_index "count_sessions", ["user_id"], :name => "index_count_sessions_on_user_id"

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

  create_table "geo_point_on_segments", :force => true do |t|
    t.integer "geo_point_id"
    t.integer "segment_id"
    t.integer "project_id"
  end

  add_index "geo_point_on_segments", ["geo_point_id"], :name => "index_geo_point_on_segments_on_geo_point_id"
  add_index "geo_point_on_segments", ["project_id"], :name => "index_geo_point_on_segments_on_project_id"
  add_index "geo_point_on_segments", ["segment_id"], :name => "index_geo_point_on_segments_on_segment_id"

  create_table "geo_points", :force => true do |t|
    t.decimal  "latitude",       :precision => 15, :scale => 10
    t.decimal  "longitude",      :precision => 15, :scale => 10
    t.decimal  "accuracy",       :precision => 5,  :scale => 2
    t.integer  "data_source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "geo_points", ["data_source_id"], :name => "index_geo_points_on_data_source_id"
  add_index "geo_points", ["project_id"], :name => "index_geo_points_on_project_id"

  create_table "model_jobs", :force => true do |t|
    t.integer  "project_id"
    t.string   "kind"
    t.text     "parameters"
    t.text     "output"
    t.boolean  "started"
    t.boolean  "finished"
    t.boolean  "picked_up"
    t.integer  "seconds_to_run"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_version", :default => 1
  end

  add_index "model_jobs", ["project_id"], :name => "index_model_jobs_on_project_id"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "url"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "postal_code"
    t.integer  "subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["subscription_id"], :name => "index_organizations_on_subscription_id"

  create_table "project_members", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.boolean  "view"
    t.boolean  "edit"
    t.boolean  "manage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_members", ["project_id"], :name => "index_project_members_on_project_id"
  add_index "project_members", ["user_id"], :name => "index_project_members_on_user_id"

  create_table "projects", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "southwest_latitude",  :precision => 15, :scale => 10
    t.decimal  "southwest_longitude", :precision => 15, :scale => 10
    t.decimal  "northeast_latitude",  :precision => 15, :scale => 10
    t.decimal  "northeast_longitude", :precision => 15, :scale => 10
    t.integer  "version"
  end

  add_index "projects", ["organization_id"], :name => "index_projects_on_organization_id"

  create_table "scenarios", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "scenarios", ["project_id"], :name => "index_scenarios_on_project_id"

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "segments", ["project_id"], :name => "index_segments_on_project_id"

  create_table "subscriptions", :force => true do |t|
    t.string   "name"
    t.boolean  "uses_ped"
    t.boolean  "uses_sign"
    t.integer  "max_users"
    t.integer  "max_projects"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                                 :default => "", :null => false
    t.string   "phone_number"
    t.integer  "organization_id"
    t.boolean  "organization_billing"
    t.boolean  "organization_manager"
    t.boolean  "orgup_admin"
    t.boolean  "orgup_api"
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["organization_id"], :name => "index_users_on_organization_id"

end
