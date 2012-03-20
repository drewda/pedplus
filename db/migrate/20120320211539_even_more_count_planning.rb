class EvenMoreCountPlanning < ActiveRecord::Migration
  def change
    add_column :count_plans, :total_weeks, :integer
  end
end