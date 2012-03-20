class MoreGateGroupAdditions < ActiveRecord::Migration
  def change
    # move a lot of the settings from CountPlan to GateGroup
    add_column :gate_groups, :color, :string
    add_column :gate_groups, :weeks, :integer
    add_column :gate_groups, :days, :string
    add_column :gate_groups, :hours, :string
    add_column :gate_groups, :status, :string
    rename_column :gate_groups, :default_counter_id, :user_id
    remove_index :gate_groups, :default_counter_id
    add_index :gate_groups, :user_id

    remove_column :count_plans, :weeks
    remove_column :count_plans, :intervening_weeks
    remove_column :count_plans, :days
    remove_column :count_plans, :hours

    remove_column :count_sessions, :duration_seconds

    add_column :count_plans, :count_session_duration_seconds, :integer

    drop_table :count_plan_segments
    drop_table :count_plan_users

    rename_column :projects, :max_number_of_counting_locations, :max_number_of_gates

    # more for counting day credits
    create_table :extra_counting_day_credits do |t|
      t.integer :organization_id
      t.boolean :used, :default => false
      t.timestamps
    end
    add_index :extra_counting_day_credits, :organization_id
  end
end
