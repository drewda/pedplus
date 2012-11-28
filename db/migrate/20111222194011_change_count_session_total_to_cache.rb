# finally implementing the correct solution:
# http://railscasts.com/episodes/23-counter-cache-column?view=asciicast

class ChangeCountSessionTotalToCache < ActiveRecord::Migration
  def self.up
  	remove_column :count_sessions, :count_total
    add_column :count_sessions, :counts_count, :integer, :default => 0
    
    CountSession.reset_column_information
  end

  def self.down
    remove_column :count_sessions, :counts_count
    add_column :count_sessions, :count_total, :integer
  end
end