# == Schema Information
#
# Table name: geo_points
#
#  id         :integer          not null, primary key
#  latitude   :decimal(15, 10)
#  longitude  :decimal(15, 10)
#  accuracy   :decimal(5, 2)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer
#
# Indexes
#
#  index_geo_points_on_project_id  (project_id)
#

class GeoPoint < ActiveRecord::Base
  belongs_to :project
  has_many :segments, :through => :geo_point_on_segments
  has_many :geo_point_on_segments
  
  accepts_nested_attributes_for :geo_point_on_segments
  
  before_destroy :clean_before_destroy
  
  def clean_before_destroy
    self.segments.each do |s|
      s.destroy()
    end
  end
  
  # to be used by Geocoder gem
  def to_coordinates
    [latitude, longitude]
  end
end
