class GeoPoint < ActiveRecord::Base
  belongs_to :data_source
  has_many :segments_a, :class_name => "Segment", :foreign_key => "geopoint_a_id"
  has_many :segments_b, :class_name => "Segment", :foreign_key => "geopoint_b_id"  
  def segments
    segments_a + segments_b
  end
end
