class GeoPointOnSegment < ActiveRecord::Base
  belongs_to :geo_point
  belongs_to :segment
end