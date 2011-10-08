class AddProjectVersions < ActiveRecord::Migration
  def change
    add_column :projects, :version, :integer
    add_column :model_jobs, :project_version, :integer, :default => 1
  end
end