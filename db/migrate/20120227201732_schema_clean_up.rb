class SchemaCleanUp < ActiveRecord::Migration
  def up
  	# this must have been a typo in 
  	# 20111222194011_change_count_session_total_to_cache.rb
  	remove_column :count_sessions, :count_total
  end
  def down
		add_column :count_sessions, :count_total, :integer
  end
end
