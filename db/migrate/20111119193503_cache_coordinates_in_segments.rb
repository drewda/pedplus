class CacheCoordinatesInSegments < ActiveRecord::Migration
  def self.up
    change_table :segments do |t|
      t.decimal :start_longitude, :precision => 15, :scale => 10
      t.decimal :start_latitude, :precision => 15, :scale => 10
      t.decimal :end_longitude, :precision => 15, :scale => 10
      t.decimal :end_latitude, :precision => 15, :scale => 10
    end
    
    Segment.all.each do |s|
      if startGeoPoint = s.geo_points.first and
         endGeoPoint = s.geo_points.last
        s.update_attributes!(
          :start_longitude => startGeoPoint.longitude,
          :start_latitude => startGeoPoint.latitude,
          :end_longitude => endGeoPoint.longitude,
          :end_latitude => endGeoPoint.latitude
        )
      end
    end
  end

  def self.down
    remove_column :segments, :end_latitude
    remove_column :segments, :end_longitude
    remove_column :segments, :start_latitude
    remove_column :segments, :start_longitude
  end
end