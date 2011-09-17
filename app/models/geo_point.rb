class GeoPoint < ActiveRecord::Base
  belongs_to :data_source
  has_many :segments, :through => :geo_point_on_segments
  has_many :geo_point_on_segments, :dependent => :destroy
  
  accepts_nested_attributes_for :geo_point_on_segments
end
