class SwitchToCountSessionTotal < ActiveRecord::Migration
  def change
    # drop_table :counts
    add_column :count_sessions, :count_total, :integer
    # to do this right switch it to :counts_count
    # http://railscasts.com/episodes/23-counter-cache-column
  end
end