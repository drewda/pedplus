class CountPlanModifications < ActiveRecord::Migration
  def up
  	rename_column :count_plans, :number_of_intervening_weeks, :intervening_weeks
  	add_column :count_plans, :is_the_current_plan, :boolean
  	remove_column :count_plans, :name
  end

  def down
  	rename_column :count_plans, :intervening_weeks, :number_of_intervening_weeks
  	remove_column :count_plans, :is_the_current_plan
  	add_column :count_plans, :name, :string
  end
end
