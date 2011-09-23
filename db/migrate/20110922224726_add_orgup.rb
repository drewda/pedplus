class AddOrgup < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.integer :organization_id
      t.boolean :organization_billing
      t.boolean :organization_manager
      t.boolean :orgup_admin
      t.boolean :orgup_api
      t.database_authenticatable
      t.invitable
      t.recoverable
      t.rememberable
      t.trackable
      t.timestamps
    end
    add_index :users, :invitation_token
    add_index :users, :organization_id
    
    create_table :organizations do |t|
      t.string :name
      t.string :slug
      t.string :url
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code
      t.integer :subscription_id
      t.timestamps
    end
    add_index :organizations, :subscription_id
    
    create_table :subscriptions do |t|
      t.string :name
      t.boolean :uses_ped
      t.boolean :uses_sign
      t.integer :max_users
      t.integer :max_projects
      t.timestamps
    end
    
    create_table :projects do |t|
      t.integer :organization_id
      t.string :name
      t.string :kind
      t.timestamps
    end
    add_index :projects, :organization_id
    
    create_table :project_members do |t|
      t.integer :user_id
      t.integer :project_id
      t.boolean :view
      t.boolean :edit
      t.boolean :manage
      t.timestamps
    end
    add_index :project_members, :user_id
    add_index :project_members, :project_id
    
    add_column :scenarios, :project_id, :integer
    add_index :scenarios, :project_id
    
    add_column :segments, :project_id, :integer
    add_index :segments, :project_id
    
    add_column :geo_points, :project_id, :integer
    add_index :geo_points, :project_id
    
    add_column :count_sessions, :project_id, :integer
    add_index :count_sessions, :project_id
    
    add_column :count_sessions, :user_id, :integer
    add_index :count_sessions, :user_id
  end
end