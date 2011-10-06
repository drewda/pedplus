# remove duplicate Segment's (and their GeoPointOnSegment's)
# written on 6 Oct 2011 because I found duplicate on the
# Big Berkeley map

# run on the console

Project.all.each do |project|
  gpPairs = project.segments.map do |s|
    {
      :segment => s.id,
      :geo_points => "#{s.geo_points.first.id}-#{s.geo_points.last.id}"
    }
  end
  gpReducedPairs = gpPairs.uniq { |gpPair| gpPair[:geo_points] }
  segmentsToKeep = gpReducedPairs.map { |gpPair| gpPair[:segment] }
  allSegmentIds = project.segments.map { |s| s.id }
  segmentsToRemove = allSegmentIds - segmentsToKeep
  Segment.where(:id => segmentsToRemove).delete_all
  GeoPointOnSegment.where(:segment_id => segmentsToRemove).delete_all
end