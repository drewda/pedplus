class SimplifyExtraCountingDayCredits < ActiveRecord::Migration
  def change
    drop_table :extra_counting_day_credits
    add_column :organizations, :extra_counting_day_credits_available, :integer, :default => 0
  end
end