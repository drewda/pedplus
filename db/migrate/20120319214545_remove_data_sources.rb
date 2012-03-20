class RemoveDataSources < ActiveRecord::Migration
  def change
    drop_table :data_sources
    remove_column :geo_points, :data_source_id
  end
end