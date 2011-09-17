class GeoPointOnSegment < ActiveRecord::Base
  belongs_to :geo_point
  belongs_to :segment
  
  before_destroy :check_segment_for_destroy
  
  def check_segment_for_destroy
    if segment.geo_point_on_segments.length <= 2
      GeoPointOnSegment.where("segment_id = ? and id != ?", segment.id, id).delete_all
      segment.destroy()
    end
  end
end