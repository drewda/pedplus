class PedCountSubscriptionChanges < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.boolean :owns_pedcount, :default => true
      t.boolean :owns_pedplus, :default => false
      t.integer :max_number_of_users, :default => 1
      t.integer :max_number_of_projects, :default => 1
      t.integer :max_number_of_segments_per_project, :default => 1000
      t.remove :subscription_id
    end
    remove_index :organizations, :subscription_id

    drop_table :subscriptions

    create_table :count_session_credits do |t|
      t.integer :organization_id
      t.string :payment_method
      t.integer :count_session_credits_purchased
      t.integer :count_session_credits_used, :default => 0
    end
  end
end
