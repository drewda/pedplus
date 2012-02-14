class AddOrganizationTimeZone < ActiveRecord::Migration
  def up
  	add_column :organizations, :time_zone, :string, :default => "Pacific Time (US & Canada)"
  end

  def down
  	remove_column :organizations, :time_zone
  end
end
