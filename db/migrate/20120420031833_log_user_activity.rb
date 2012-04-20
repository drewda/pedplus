class LogUserActivity < ActiveRecord::Migration
  def change
    create_table :log_entries do |t|
      t.integer :user_id
      t.integer :organization_id
      t.integer :project_id
      t.integer :model_job_id
      t.integer :count_plan_id
      t.integer :count_session_id
      t.string :kind
      t.string :note
      t.timestamps
    end
  end
end