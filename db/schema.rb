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

ActiveRecord::Schema.define(:version => 20120813185604) do

  create_table "count_plans", :force => true do |t|
    t.integer  "project_id"
    t.date     "start_date"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "is_the_current_plan"
    t.integer  "count_session_duration_seconds"
    t.integer  "total_weeks"
  end

  add_index "count_plans", ["project_id"], :name => "index_count_plans_on_project_id"

  create_table "count_sessions", :force => true do |t|
    t.datetime "start"
    t.datetime "stop"
    t.string   "status"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "counts_count",  :default => 0
    t.integer  "count_plan_id"
    t.integer  "gate_id"
  end

  add_index "count_sessions", ["count_plan_id"], :name => "index_count_sessions_on_count_plan_id"
  add_index "count_sessions", ["project_id"], :name => "index_count_sessions_on_project_id"
  add_index "count_sessions", ["user_id"], :name => "index_count_sessions_on_user_id"

  create_table "counts", :force => true do |t|
    t.integer  "count_session_id"
    t.datetime "at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "counts", ["count_session_id"], :name => "index_counts_on_count_session_id"

  create_table "gate_groups", :force => true do |t|
    t.integer  "count_plan_id"
    t.integer  "user_id"
    t.string   "label"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "days"
    t.string   "hours"
    t.string   "status"
  end

  add_index "gate_groups", ["count_plan_id"], :name => "index_gate_groups_on_count_plan_id"
  add_index "gate_groups", ["user_id"], :name => "index_gate_groups_on_user_id"

  create_table "gates", :force => true do |t|
    t.integer  "segment_id"
    t.integer  "gate_group_id"
    t.integer  "count_plan_id"
    t.integer  "counting_days_remaining"
    t.string   "label"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "gates", ["count_plan_id"], :name => "index_gates_on_count_plan_id"
  add_index "gates", ["gate_group_id"], :name => "index_gates_on_gate_group_id"
  add_index "gates", ["segment_id"], :name => "index_gates_on_segment_id"

  create_table "geo_point_on_segments", :force => true do |t|
    t.integer "geo_point_id"
    t.integer "segment_id"
    t.integer "project_id"
  end

  add_index "geo_point_on_segments", ["geo_point_id"], :name => "index_geo_point_on_segments_on_geo_point_id"
  add_index "geo_point_on_segments", ["project_id"], :name => "index_geo_point_on_segments_on_project_id"
  add_index "geo_point_on_segments", ["segment_id"], :name => "index_geo_point_on_segments_on_segment_id"

  create_table "geo_points", :force => true do |t|
    t.decimal  "latitude",   :precision => 15, :scale => 10
    t.decimal  "longitude",  :precision => 15, :scale => 10
    t.decimal  "accuracy",   :precision => 5,  :scale => 2
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "project_id"
  end

  add_index "geo_points", ["project_id"], :name => "index_geo_points_on_project_id"

  create_table "log_entries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.integer  "project_id"
    t.integer  "model_job_id"
    t.integer  "count_plan_id"
    t.integer  "count_session_id"
    t.string   "kind"
    t.string   "note"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "model_jobs", :force => true do |t|
    t.integer  "project_id"
    t.string   "kind"
    t.text     "parameters"
    t.text     "output"
    t.boolean  "started"
    t.boolean  "finished"
    t.boolean  "picked_up"
    t.integer  "seconds_to_run"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
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
    t.datetime "created_at",                                                                        :null => false
    t.datetime "updated_at",                                                                        :null => false
    t.boolean  "owns_pedcount",                           :default => true
    t.boolean  "owns_pedplus",                            :default => false
    t.integer  "max_number_of_users",                     :default => 1
    t.integer  "max_number_of_projects",                  :default => 1
    t.string   "time_zone",                               :default => "Pacific Time (US & Canada)"
    t.string   "kind"
    t.integer  "default_max_number_of_gates_per_project"
    t.date     "subscription_active_until"
    t.integer  "default_counting_days_per_gate"
    t.integer  "extra_counting_day_credits_available",    :default => 0
    t.boolean  "allowed_to_export_projects",              :default => false
  end

  create_table "project_members", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.boolean  "view"
    t.boolean  "manage"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "count",      :default => false
    t.boolean  "map"
    t.boolean  "plan"
  end

  add_index "project_members", ["project_id"], :name => "index_project_members_on_project_id"
  add_index "project_members", ["user_id"], :name => "index_project_members_on_user_id"

  create_table "projects", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "kind"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.decimal  "southwest_latitude",  :precision => 15, :scale => 10
    t.decimal  "southwest_longitude", :precision => 15, :scale => 10
    t.decimal  "northeast_latitude",  :precision => 15, :scale => 10
    t.decimal  "northeast_longitude", :precision => 15, :scale => 10
    t.integer  "version"
    t.integer  "max_number_of_gates"
    t.string   "base_map",                                            :default => "osm"
    t.boolean  "allowed_to_export",                                   :default => false
  end

  add_index "projects", ["organization_id"], :name => "index_projects_on_organization_id"

  create_table "scenarios", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "project_id"
  end

  add_index "scenarios", ["project_id"], :name => "index_scenarios_on_project_id"

  create_table "segment_in_scenarios", :force => true do |t|
    t.integer  "scenario_id"
    t.integer  "segment_id"
    t.string   "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "segment_in_scenarios", ["scenario_id"], :name => "index_segment_in_scenarios_on_scenario_id"
  add_index "segment_in_scenarios", ["segment_id"], :name => "index_segment_in_scenarios_on_segment_id"

  create_table "segments", :force => true do |t|
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "project_id"
    t.decimal  "start_longitude", :precision => 15, :scale => 10
    t.decimal  "start_latitude",  :precision => 15, :scale => 10
    t.decimal  "end_longitude",   :precision => 15, :scale => 10
    t.decimal  "end_latitude",    :precision => 15, :scale => 10
  end

  add_index "segments", ["project_id"], :name => "index_segments_on_project_id"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.integer  "organization_id"
    t.boolean  "organization_billing"
    t.boolean  "organization_manager"
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "s3sol_admin"
    t.string   "authentication_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["organization_id"], :name => "index_users_on_organization_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
