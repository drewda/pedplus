class AddDurationToCountSession < ActiveRecord::Migration
  def up
  	add_column :count_sessions, :duration_seconds, :integer
  end

  def down
  	remove_column :count_sessions, :duration_seconds
  end
end
