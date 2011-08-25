class Segment < ActiveRecord::Base
  belongs_to :ped_project
  has_many :count_sessions
  has_many :segment_in_scenarios
  has_many :scenarios, :through => :segment_in_scenarios
  belongs_to :geopoint_a, :class_name => "GeoPoint"
  belongs_to :geopoint_b, :class_name => "GeoPoint"
end
