class PedCountPermissionChanges < ActiveRecord::Migration
  def up
    add_column :project_members, :count, :boolean, :default => false
    add_column :project_members, :map, :boolean
    add_column :project_members, :plan, :boolean
    ProjectMember.all.each { |pm| pm.update_attribute :map, pm.edit }
    remove_column :project_members, :edit

    add_column :users, :s3sol_admin, :boolean
    User.all.each { |u| u.update_attribute :s3sol_admin, u.orgup_admin }
    remove_column :users, :orgup_admin
    remove_column :users, :orgup_api
  end

  def down
    remove_column :project_members, :count
    remove_column :project_members, :map
    remove_column :project_members, :plan
    add_column :project_members, :edit, :boolean
    add_column :project_members, :view, :boolean

    remove_column :users, :s3sol_admin
    add_column :users, :orgup_admin, :boolean
    add_column :users, :orgup_api, :boolean
  end
end
