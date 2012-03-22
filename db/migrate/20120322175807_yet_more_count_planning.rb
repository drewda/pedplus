class YetMoreCountPlanning < ActiveRecord::Migration
  def change
  	remove_column :gate_groups, :color
  end
end
