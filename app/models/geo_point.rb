class GeoPoint < ActiveRecord::Base
  belongs_to :project
  belongs_to :data_source
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
