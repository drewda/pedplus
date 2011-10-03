class CacheProjectBoundingBox < ActiveRecord::Migration
  def change
    add_column :projects, :southwest_latitude, :decimal, :precision => 15, :scale => 10
    add_column :projects, :southwest_longitude, :decimal, :precision => 15, :scale => 10
    add_column :projects, :northeast_latitude, :decimal, :precision => 15, :scale => 10
    add_column :projects, :northeast_longitude, :decimal, :precision => 15, :scale => 10
  end
end