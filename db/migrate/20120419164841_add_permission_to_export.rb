class AddPermissionToExport < ActiveRecord::Migration
  def change
  	add_column :organizations, :allowed_to_export_projects, :boolean, :default => false
  	add_column :projects, :allowed_to_export, :boolean, :default => false
  end
end
