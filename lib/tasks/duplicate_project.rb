oldProject = Project.find(4)

newProject = oldProject.dup
newProject.name = "Redlands (Scratch Work)"
newProject.save()

segmentTranslations = Hash.new

oldProject.segments.each do |oldSegment|
  newSegment = oldSegment.dup
  newSegment.project = newProject
  newSegment.save()
  segmentTranslations[oldSegment.id] = newSegment.id
end

geoPointTranslations = Hash.new

oldProject.geo_points.each do |oldGeoPoint|
  newGeoPoint = oldGeoPoint.dup
  newGeoPoint.project = newProject
  newGeoPoint.save()
  geoPointTranslations[oldGeoPoint.id] = newGeoPoint.id
end

oldProject.geo_point_on_segments.each do |oldGeoPointOnSegment|
  oldGeoPointId = oldGeoPointOnSegment.geo_point.id
  oldSegmentId = oldGeoPointOnSegment.segment.id
  
  newGeoPointId = geoPointTranslations[oldGeoPointId]
  newSegmentId = segmentTranslations[oldSegmentId]
  
  GeoPointOnSegment.create(:project => newProject, :geo_point_id => newGeoPointId, :segment_id => newSegmentId)
end
