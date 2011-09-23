class Segment < ActiveRecord::Base
  belongs_to :project
  has_many :count_sessions
  has_many :segment_in_scenarios
  has_many :scenarios, :through => :segment_in_scenarios
  has_many :geo_points, :through => :geo_point_on_segments
  has_many :geo_point_on_segments
  
  accepts_nested_attributes_for :geo_point_on_segments
  
  before_destroy :clean_before_destroy
  
  def clean_before_destroy
    self.geo_point_on_segments.each do |gpos|
      gpos.delete()
    end
  end
end
