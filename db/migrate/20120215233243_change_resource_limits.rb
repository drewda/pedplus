class ChangeResourceLimits < ActiveRecord::Migration
  def up
    remove_column :organizations, :max_number_of_segments_per_project

    add_column :organizations, :kind, :string

    add_column :organizations, :default_max_number_of_counting_locations_per_project, :integer
    add_column :projects, :max_number_of_counting_locations, :integer

    drop_table :count_session_credits

    add_column :organizations, :default_number_of_counting_day_credits_per_user, :integer
    add_column :users, :counting_day_credits, :integer

    add_column :organizations, :subscription_active_until, :date
  end

  def down
    add_column :organizations, :max_number_of_segments_per_project, :integer, :default => 1000

    remove_column :organizations, :kind

    remove_column :organizations, :default_max_number_of_counting_locations_per_project
    remove_column :projects, :max_number_of_counting_locations

    create_table :count_session_credits do |t|
      t.integer :organization_id
      t.string :payment_method
      t.integer :count_session_credits_purchased
      t.integer :count_session_credits_used, :default => 0
    end

    remove_column :organizations, :default_number_of_counting_day_credits_per_user
    remove_column :users, :counting_day_credits

    remove_column :organizations, :subscription_active_until
  end
end
