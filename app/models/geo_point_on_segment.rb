class GeoPointOnSegment < ActiveRecord::Base
  belongs_to :geo_point
  belongs_to :segment
  belongs_to :project
  
  validates_uniqueness_of :geo_point_id, :scope => :segment_id
end