# == Schema Information
#
# Table name: geo_point_on_segments
#
#  id           :integer          not null, primary key
#  geo_point_id :integer
#  segment_id   :integer
#  project_id   :integer
#
# Indexes
#
#  index_geo_point_on_segments_on_geo_point_id  (geo_point_id)
#  index_geo_point_on_segments_on_project_id    (project_id)
#  index_geo_point_on_segments_on_segment_id    (segment_id)
#

class GeoPointOnSegment < ActiveRecord::Base
  belongs_to :geo_point
  belongs_to :segment
  belongs_to :project
  
  validates_uniqueness_of :geo_point_id, :scope => :segment_id
end
