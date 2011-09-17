class Segment < ActiveRecord::Base
  belongs_to :ped_project
  has_many :count_sessions
  has_many :segment_in_scenarios
  has_many :scenarios, :through => :segment_in_scenarios
  has_many :geo_points, :through => :geo_point_on_segments
  has_many :geo_point_on_segments
  
  accepts_nested_attributes_for :geo_point_on_segments
end
