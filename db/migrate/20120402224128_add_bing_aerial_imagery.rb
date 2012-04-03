class AddBingAerialImagery < ActiveRecord::Migration
  def change
  	add_column :projects, :base_map, :string, :default => 'osm'
  end
end
