class AddGatesAndRemoveCountingDayCredits < ActiveRecord::Migration
  def change
    create_table :gates do |t|
      t.integer :segment_id
      t.integer :gate_group_id
      t.integer :count_plan_id
      t.integer :counting_days_remaining
      t.string :label

      t.timestamps
    end
    add_index :gates, :segment_id
    add_index :gates, :gate_group_id
    add_index :gates, :count_plan_id

    create_table :gate_groups do |t|
      t.integer :count_plan_id
      t.integer :default_counter_id # User
      t.string :label

      t.timestamps
    end
    add_index :gate_groups, :count_plan_id
    add_index :gate_groups, :default_counter_id

    remove_column :count_sessions, :segment_id
    add_column :count_sessions, :gate_id, :integer

    # we'll now be throttling by the number of days a gate is counted (PEDPLUS-59)
    remove_column :users, :counting_day_credits
    remove_column :organizations, :default_number_of_counting_day_credits_per_user
    rename_column :organizations, :default_max_number_of_counting_locations_per_project, :default_max_number_of_gates_per_project
    add_column :organizations, :default_counting_days_per_gate, :integer
  end
end
