class AddModelJobs < ActiveRecord::Migration
  def change
    create_table :model_jobs, :force => true do |t|
      t.integer :project_id
      t.string :kind
      t.text :parameters
      t.text :output
      t.boolean :started
      t.boolean :finished
      t.boolean :picked_up
      t.integer :seconds_to_run
      
      t.timestamps
    end
    add_index :model_jobs, :project_id
  end
end