class EvenMoreCountPlanning < ActiveRecord::Migration
  def change
    add_column :count_plans, :total_weeks, :integer
    remove_column :gate_groups, :weeks
  end
end