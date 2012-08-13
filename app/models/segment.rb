# == Schema Information
#
# Table name: segments
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  project_id      :integer
#  start_longitude :decimal(15, 10)
#  start_latitude  :decimal(15, 10)
#  end_longitude   :decimal(15, 10)
#  end_latitude    :decimal(15, 10)
#
# Indexes
#
#  index_segments_on_project_id  (project_id)
#

class Segment < ActiveRecord::Base
  belongs_to :project
  has_many :count_plans, :through => :count_plan_segments # TODO: destroy???
  has_many :gates, :dependent => :destroy
  has_many :segment_in_scenarios, :dependent => :destroy
  has_many :scenarios, :through => :segment_in_scenarios
  has_many :geo_points, :through => :geo_point_on_segments
  has_many :geo_point_on_segments, :dependent => :destroy
  
  accepts_nested_attributes_for :geo_point_on_segments
  
  before_destroy :clean_before_destroy
  
  def clean_before_destroy
    self.geo_point_on_segments.each do |gpos|
      gpos.delete()
    end
  end
  
  def connected_segments
    segmentId = self.id
    connected_segments = []
    self.geo_points.each do |gp| 
      gp.segments.each do |s|
        connected_segments.push s unless s.id == segmentId
      end
    end
    connected_segments
  end
  
  def length
    Geocoder::Calculations.distance_between self.geo_points[0], self.geo_points[1] # miles
  end
end
