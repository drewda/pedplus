class CountPlanningAssistant < ActiveRecord::Migration
  def up
    create_table :count_plans do |t|
      t.string :name
      t.integer :project_id
      t.date :start_date
      t.integer :weeks
      t.integer :number_of_intervening_weeks
      t.string :days
      t.string :hours

      t.timestamps
    end
    add_index :count_plans, :project_id

    create_table :count_plan_users do |t|
      t.integer :count_plan_id
      t.integer :user_id
    end
    add_index :count_plan_users, :count_plan_id
    add_index :count_plan_users, :user_id

    create_table :count_plan_segments do |t|
      t.integer :count_plan_id
      t.integer :segment_id
    end
    add_index :count_plan_segments, :count_plan_id
    add_index :count_plan_segments, :segment_id

    add_column :count_sessions, :count_plan_id, :integer
    add_index :count_sessions, :count_plan_id
  end

  def down
    drop_table :count_plans
    drop_table :count_plan_users
    drop_table :count_plan_segments
    remove_column :count_sessions, :count_plan_id
  end
end